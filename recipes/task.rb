#
# Author:: Paul Mooring (<paul@opscode.com>)
# Cookbook Name:: chef
# Recipe:: task
#
# Copyright 2011, Opscode, Inc.
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

class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end
# libraries/helpers.rb method to DRY directory creation resources
client_bin = find_chef_client
node.set["chef_client"]["bin"] = client_bin
create_directories

if node['chef_client']['task']['use_cron_schedule']
  frequency, frequency_modifier, start_time = cron_to_task_schedule(node['chef_client']['cron']['minute'], node['chef_client']['cron']['hour'])
else
  frequency = :minute
  frequency_modifier = node['chef_client']['interval'].to_i / 60
  start_time = nil
end

windows_task "chef-client" do
  run_level :highest
  command "cmd /c \"#{node['chef_client']['ruby_bin']} #{node['chef_client']['bin']} \
  -L #{File.join(node['chef_client']['log_dir'], 'client.log')} \
  -c #{File.join(node['chef_client']['conf_dir'], 'client.rb')} -s #{node['chef_client']['splay']} > NUL 2>&1\""

  user               node['chef_client']['task']['user']
  password           node['chef_client']['task']['password']
  frequency          frequency
  frequency_modifier frequency_modifier
  start_time         start_time.strftime('%H:%M') if start_time
end

