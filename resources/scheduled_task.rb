#
# Cookbook:: chef-client
# resource:: chef_client_scheduled_task
#
# Copyright:: 2017, Chef Software, Inc.
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

resource_name :chef_client_scheduled_task

property :user, String, default: 'System'
property :password, String
property :frequency, String, default: 'minute'
property :frequency_modifier, Integer, default: 30
property :start_time, String
property :splay, [Integer, String], default: 300
property :config_directory, String, default: 'C:/chef'
property :log_directory, String, default: lazy { |r| "#{r.config_directory}/log" }
property :chef_binary_path, String, default: 'C:/opscode/chef/bin/chef-client'
property :daemon_options, Array, default: []

action :add do
  create_chef_directories

  # Build command line to pass to cmd.exe
  client_cmd = new_resource.chef_binary_path.dup
  client_cmd << " -L #{::File.join(new_resource.log_directory, node['chef_client']['log_file'])}"
  client_cmd << " -c #{::File.join(new_resource.config_directory, 'client.rb')}"
  client_cmd << " -s #{new_resource.splay}"

  # Add custom options
  client_cmd << " #{new_resource.daemon_options.join(' ')}" if new_resource.daemon_options.any?

  start_time = new_resource.frequency == 'minute' ? (Time.now + 60 * new_resource.frequency_modifier).strftime('%H:%M') : nil
  windows_task 'chef-client' do
    run_level :highest
    command "cmd /c \"#{client_cmd}\""

    user               new_resource.user
    password           new_resource.password
    frequency          new_resource.frequency.to_sym
    frequency_modifier new_resource.frequency_modifier
    start_time         new_resource.start_time || start_time
  end
end

action :remove do
  windows_task 'chef-client' do
    action :delete
  end
end
