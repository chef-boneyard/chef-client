#
# Author:: Paul Mooring (<paul@chef.io>)
# Cookbook:: chef-client
# Recipe:: task
#
# Copyright:: 2011-2020, Chef Software, Inc.
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
client_bin = find_chef_client
Chef::Log.info("Using chef-client binary at #{client_bin}")
node.default['chef_client']['bin'] = client_bin

chef_client_scheduled_task 'Chef Client' do
  user node['chef_client']['task']['user']
  password node['chef_client']['task']['password']
  frequency node['chef_client']['task']['frequency']
  frequency_modifier lazy { node['chef_client']['task']['frequency_modifier'] }
  start_time node['chef_client']['task']['start_time']
  start_date node['chef_client']['task']['start_date']
  splay node['chef_client']['splay']
  config_directory node['chef_client']['conf_dir']
  log_directory node['chef_client']['log_dir']
  chef_binary_path node['chef_client']['bin']
  daemon_options node['chef_client']['daemon_options']
  task_name node['chef_client']['task']['name']
end

windows_service 'chef-client' do
  startup_type :disabled
  action [:configure_startup, :stop]
  ignore_failure true
  only_if { ::Win32::Service.exists?('chef-client') }
end
