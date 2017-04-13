#
# Author:: Joshua Timberman (<joshua@chef.io>)
# Author:: Joshua Sierles (<joshua@37signals.com>)
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Cookbook::  chef-client
# Recipe:: config
#
# Copyright:: 2008-2017, Chef Software, Inc.
# Copyright:: 2009-2017, 37signals
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# include helper methods
class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

# chef_node_name = Chef::Config[:node_name] == node['fqdn'] ? false : Chef::Config[:node_name]

if node['chef_client']['log_file'].is_a?(String) && node['chef_client']['init_style'] != 'runit'
  log_path = File.join(node['chef_client']['log_dir'], node['chef_client']['log_file'])
  node.default['chef_client']['config']['log_location'] = log_path

  case node['platform_family']
  when 'amazon', 'rhel', 'debian', 'fedora'
    logrotate_app 'chef-client' do
      path [log_path]
      rotate node['chef_client']['logrotate']['rotate']
      frequency node['chef_client']['logrotate']['frequency']
      options node['chef_client']['log_rotation']['options']
      prerotate node['chef_client']['log_rotation']['prerotate']
      postrotate node['chef_client']['log_rotation']['postrotate']
      template_mode '0644'
    end
  end
else
  log_path = 'STDOUT'
end

# libraries/helpers.rb method to DRY directory creation resources
create_chef_directories

if log_path != 'STDOUT' # ~FC023
  file log_path do
    mode node['chef_client']['log_perm']
  end
end

chef_requires = []
node['chef_client']['load_gems'].each do |gem_name, gem_info_hash|
  gem_info_hash ||= {}
  chef_gem gem_name do
    compile_time true
    action gem_info_hash[:action] || :install
    source gem_info_hash[:source] if gem_info_hash[:source]
    version gem_info_hash[:version] if gem_info_hash[:version]
    options gem_info_hash[:options] if gem_info_hash[:options]
    retries gem_info_hash[:retries] if gem_info_hash[:retries]
    retry_delay gem_info_hash[:retry_delay] if gem_info_hash[:retry_delay]
    timeout gem_info_hash[:timeout] if gem_info_hash[:timeout]
  end
  chef_requires.push(gem_info_hash[:require_name] || gem_name)
end

# We need to set these local variables because the methods aren't
# available in the Chef::Resource scope
d_owner = root_owner

template "#{node['chef_client']['conf_dir']}/client.rb" do
  source 'client.rb.erb'
  owner d_owner
  group node['root_group']
  mode '644'
  variables(
    chef_config: node['chef_client']['config'],
    chef_requires: chef_requires,
    ohai_disabled_plugins: node['ohai']['disabled_plugins'],
    ohai_new_config_syntax: Gem::Requirement.new('>= 8.6.0').satisfied_by?(Gem::Version.new(Ohai::VERSION)),
    start_handlers: node['chef_client']['config']['start_handlers'],
    report_handlers: node['chef_client']['config']['report_handlers'],
    exception_handlers: node['chef_client']['config']['exception_handlers']
  )

  if node['chef_client']['reload_config']
    notifies :create, 'ruby_block[reload_client_config]', :immediately
  end
end

directory ::File.join(node['chef_client']['conf_dir'], 'client.d') do
  recursive true
  owner d_owner
  group node['root_group']
  mode '755'
end

ruby_block 'reload_client_config' do
  block do
    Chef::Config.from_file("#{node['chef_client']['conf_dir']}/client.rb")
  end
  action :nothing
end
