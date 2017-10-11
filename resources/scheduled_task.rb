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

property :user, String, default: node['chef_client']['task']['user']
property :password, String
property :frequency, String, default: node['chef_client']['task']['frequency']
property :frequency_modifier, Integer, default: node['chef_client']['task']['frequency_modifier']
property :start_time, String, default: node['chef_client']['task']['start_time']
property :splay, [Integer, String], default: node['chef_client']['splay']
property :config_directory, String, default: 'C:/chef'
property :log_directory, String, default: lazy { |r| "#{r.config_directory}/log" }
property :chef_binary_path, String, default: 'C:/opscode/chef/bin/chef-client'
property :daemon_options, Array, default: []
property :task_name, String, default: node['chef-client']['task']['task_name']

def load_task_hash(task_name)
  Chef::Log.debug 'Looking for existing tasks'

  # we use powershell_out here instead of powershell_out! because a failure implies that the task does not exist
  task_script = <<-EOH
    [Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8
    schtasks /Query /FO LIST /V /TN \"#{task_name}\"
  EOH
  output = powershell_out(task_script).stdout.force_encoding('UTF-8')
  if output.empty?
    task = false
  else
    task = {}

    output.split("\n").map! { |line| line.split(':', 2).map!(&:strip) }.each do |field|
      if field.is_a?(Array) && field[0].respond_to?(:to_sym)
        task[field[0].gsub(/\s+/, '').to_sym] = field[1]
      end
    end
  end

  task
end

load_current_value do |desired|
  pathed_task_name = desired.task_name.start_with?('\\') ? desired.task_name : "\\#{desired.task_name}"

  task_hash = load_task_hash pathed_task_name

  task_name pathed_task_name
  if task_hash.respond_to?(:[]) && task_hash[:TaskName] == pathed_task_name
    user task_hash[:RunAsUser]
    start_time task_hash[:StartTime]
    frequency task_hash[:ScheduleType]
  end
end

action :add do
  create_chef_directories

  # Build command line to pass to cmd.exe
  client_cmd = new_resource.chef_binary_path.dup
  client_cmd << " -L #{::File.join(new_resource.log_directory, node['chef_client']['log_file'])}"
  client_cmd << " -c #{::File.join(new_resource.config_directory, 'client.rb')}"
  client_cmd << " -s #{new_resource.splay}"

  # Add custom options
  client_cmd << " #{new_resource.daemon_options.join(' ')}" if new_resource.daemon_options.any?

  #start_time = new_resource.frequency == 'minute' ? (Time.now + 60 * new_resource.frequency_modifier).strftime('%H:%M') : nil
  windows_task 'chef-client' do
    run_level :highest
    command "cmd /c \"#{client_cmd}\""

    user               new_resource.user
    password           new_resource.password
    frequency          new_resource.frequency.to_sym
    frequency_modifier new_resource.frequency_modifier
    start_time         new_resource.start_time
  end
end

action :remove do
  windows_task 'chef-client' do
    action :delete
  end
end

action :create do
  converge_if_changed :user do
    windows_task 'chef-client' do
      user new_resource.user
    end
  end
  converge_if_changed :frequency do
    windows_task 'chef-client' do
      frequency new_resource.frequency
    end
  end
  converge_if_changed :frequency_modifier do
    windows_task 'chef-client' do
      frequency_modifier new_resource.frequency_modifier
    end
  end
  converge_if_changed :start_time do
    windows_task 'chef-client' do
      start_time new_resource.start_time
    end
  end
end
