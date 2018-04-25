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
property :frequency, String, default: 'minute', equal_to: %w(minute hourly daily monthly once on_logon onstart on_idle)
property :frequency_modifier, [Integer, String], default: 30
property :start_date, String, regex: [%r{^[0-1][0-9]\/[0-3][0-9]\/\d{4}$}]
property :start_time, String, regex: [/^\d{2}:\d{2}$/]
property :splay, [Integer, String], default: 300
property :config_directory, String, default: 'C:/chef'
property :log_directory, String, default: lazy { |r| "#{r.config_directory}/log" }
property :chef_binary_path, String, default: 'C:/opscode/chef/bin/chef-client'
property :daemon_options, Array, default: []
property :task_name, String, default: 'chef-client'

action :add do
  create_chef_directories

  # Build command line to pass to cmd.exe
  client_cmd = new_resource.chef_binary_path.dup
  client_cmd << " -L #{::File.join(new_resource.log_directory, node['chef_client']['log_file'])}" unless node['chef_client']['log_file'].nil?
  client_cmd << " -c #{::File.join(new_resource.config_directory, 'client.rb')}"
  client_cmd << " -s #{new_resource.splay}"

  # Add custom options
  client_cmd << " #{new_resource.daemon_options.join(' ')}" if new_resource.daemon_options.any?

  # This block is here due to the changes in windows_task in 13.7
  # This can be removed once we no longer support < 13.7
  full_command = if Gem::Requirement.new('< 13.7.0').satisfied_by?(Gem::Version.new(Chef::VERSION))
                   "cmd /c \"#{client_cmd}\""
                 else
                   "cmd /c \'#{client_cmd}\'"
                 end

  windows_task new_resource.task_name do
    run_level :highest
    command full_command
    user               new_resource.user
    password           new_resource.password
    frequency          new_resource.frequency.to_sym
    frequency_modifier new_resource.frequency_modifier
    start_time         start_time_value
    start_day          new_resource.start_date unless new_resource.start_date.nil?
  end
end

action :remove do
  windows_task new_resource.task_name do
    action :delete
  end
end

action_class do
  # @todo this can all get removed when we don't support Chef 13.6 anymore
  def start_time_value
    if new_resource.start_time
      new_resource.start_time
    elsif Gem::Requirement.new('< 13.7.0').satisfied_by?(Gem::Version.new(Chef::VERSION))
      new_resource.frequency == 'minute' ? (Time.now + 60 * new_resource.frequency_modifier.to_f).strftime('%H:%M') : nil
    end
  end
end
