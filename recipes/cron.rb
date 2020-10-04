#
# Author:: Joshua Timberman (<joshua@chef.io>)
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Author:: Bryan Berry (<bryan.berry@gmail.com>)
# Cookbook::  chef-client
# Recipe:: cron
#
# Copyright:: 2009-2019, Chef Software Inc.
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
#

# include helper methods
class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

# libraries/helpers.rb method to DRY directory creation resources
create_chef_directories

# Stop any running chef-client services
if node['os'] == 'linux'
  service 'chef-client' do
    supports status: true, restart: true
    action [:disable, :stop]
    ignore_failure true
  end

  file '/etc/init.d/chef-client' do
    action :delete
  end
end

case node['platform_family']
when 'openindiana', 'opensolaris', 'nexentacore', 'solaris2', 'smartos', 'omnios'
  service 'chef-client' do
    supports status: true, restart: true
    action [:disable, :stop]
    ignore_failure true
  end

when 'freebsd'
  template '/etc/rc.d/chef-client' do
    source 'freebsd/chef-client.erb'
    owner 'root'
    group 'wheel'
    variables client_bin: node['chef_client']['bin']
    mode '0755'
  end

  file '/etc/rc.conf.d/chef' do
    action :delete
  end

  service 'chef-client' do
    supports status: true, restart: true
    action [:stop]
  end
end

# If "use_cron_d" is set to true, delete the cron entry that uses the cron
# resource built in to Chef and instead use the cron_d LWRP.
if node['chef_client']['cron']['use_cron_d']
  cron 'chef-client' do
    action :delete
  end

  chef_client_cron 'chef-client cron.d job' do
    minute            node['chef_client']['cron']['minute']
    hour              node['chef_client']['cron']['hour']
    weekday           node['chef_client']['cron']['weekday']
    chef_binary_path  node['chef_client']['bin'] if node['chef_client']['bin']
    mailto            node['chef_client']['cron']['mailto'] if node['chef_client']['cron']['mailto']
    splay             node['chef_client']['splay']
    log_file_name     node['chef_client']['cron']['log_file']
    append_log_file   node['chef_client']['cron']['append_log']
    daemon_options    node['chef_client']['daemon_options']
    environment       node['chef_client']['cron']['environment_variables'] if node['chef_client']['cron']['environment_variables']
  end
else
  # Non-linux platforms don't support cron.d so we won't try to remove a cron_d resource.
  # https://github.com/chef-cookbooks/cron/blob/master/resources/d.rb#L55
  if node['os'] == 'linux'
    cron_d 'chef-client' do
      action :delete
    end
  end

  sleep_time = splay_sleep_time(node['chef_client']['splay'].to_i)
  log_file   = node['chef_client']['cron']['log_file']
  append_log = node['chef_client']['cron']['append_log'] ? '>>' : '>'
  daemon_options = " #{node['chef_client']['daemon_options'].join(' ')} " if node['chef_client']['daemon_options'].any?

  cron 'chef-client' do
    minute  node['chef_client']['cron']['minute']
    hour    node['chef_client']['cron']['hour']
    weekday node['chef_client']['cron']['weekday']
    path    node['chef_client']['cron']['path'] if node['chef_client']['cron']['path']
    mailto  node['chef_client']['cron']['mailto'] if node['chef_client']['cron']['mailto']
    user    'root'
    cmd = ''
    cmd << "/bin/sleep #{sleep_time}; " if sleep_time
    cmd << "#{env_vars} " if env_vars?
    cmd << "#{node['chef_client']['cron']['nice_path']} -n #{process_priority} " if process_priority
    cmd << "#{node['chef_client']['bin']} #{daemon_options}#{append_log} #{log_file} 2>&1"
    cmd << ' || echo "Chef client execution failed"' if node['chef_client']['cron']['mailto']
    command cmd
  end
end
