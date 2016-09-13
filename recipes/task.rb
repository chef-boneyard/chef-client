#
# Author:: Paul Mooring (<paul@chef.io>)
# Cookbook Name:: chef
# Recipe:: task
#
# Copyright 2011-2016, Chef Software, Inc.
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
node.default['chef_client']['bin'] = client_bin
create_directories

# Build command line to pass to cmd.exe
client_cmd = "#{node['chef_client']['ruby_bin']} #{node['chef_client']['bin']}"
client_cmd << " -L #{File.join(node['chef_client']['log_dir'], 'client.log')}"
client_cmd << " -c #{File.join(node['chef_client']['conf_dir'], 'client.rb')}"
client_cmd << " -s #{node['chef_client']['splay']}"

# Add custom options
client_cmd << " #{node['chef_client']['daemon_options'].join(' ')}" if node['chef_client']['daemon_options'].any?

log 'debug client_cmd' do
  message "Final client_cmd: #{client_cmd}"
  level :debug
end

start_time = node['chef_client']['task']['frequency'] == 'minute' ? (Time.now + 60 * node['chef_client']['task']['frequency_modifier']).strftime('%H:%M') : nil
windows_task 'chef-client' do
  run_level :highest
  command "cmd /c \"#{client_cmd} ^> NUL 2^>^&1\""

  user               node['chef_client']['task']['user']
  password           node['chef_client']['task']['password']
  frequency          node['chef_client']['task']['frequency'].to_sym
  frequency_modifier node['chef_client']['task']['frequency_modifier']
  start_time         node['chef_client']['task']['start_time'] || start_time
end
