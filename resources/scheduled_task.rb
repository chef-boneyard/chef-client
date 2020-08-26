#
# Cookbook:: chef-client
# resource:: chef_client_scheduled_task
#
# Copyright:: 2017-2020, Chef Software, Inc.
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

chef_version_for_provides '< 16.0' if respond_to?(:chef_version_for_provides)

provides :chef_client_scheduled_task
resource_name :chef_client_scheduled_task

property :task_name, String,
  default: 'chef-client'

property :user, String,
  default: 'System', sensitive: true

property :password, String,
  sensitive: true

property :frequency, String,
  default: 'minute',
  equal_to: %w(minute hourly daily monthly once on_logon onstart on_idle)

property :frequency_modifier, [Integer, String],
  coerce: proc { |x| Integer(x) },
  callbacks: { 'should be a positive number' => proc { |v| v > 0 } },
  default: lazy { frequency == 'minute' ? 30 : 1 }

property :accept_chef_license, [true, false],
  default: false

property :start_date, String,
  regex: [%r{^[0-1][0-9]\/[0-3][0-9]\/\d{4}$}]

property :start_time, String,
  regex: [/^\d{2}:\d{2}$/]

property :splay, [Integer, String],
  coerce: proc { |x| Integer(x) },
  callbacks: { 'should be a positive number' => proc { |v| v > 0 } },
  default: 300

property :run_on_battery, [true, false],
  default: true

property :config_directory, String,
  default: 'C:/chef'

property :log_directory, String,
  default: lazy { |r| "#{r.config_directory}/log" }

property :log_file_name, String,
  default: 'client.log'

property :chef_binary_path, String,
  default: 'C:/opscode/chef/bin/chef-client'

property :daemon_options, Array,
  default: lazy { [] }

action :add do
  # create a directory in case the log directory does not exist
  unless Dir.exist?(new_resource.log_directory)
    directory new_resource.log_directory do
      inherits true
      recursive true
      action :create
    end
  end

  # According to https://docs.microsoft.com/en-us/windows/desktop/taskschd/schtasks,
  # the :once, :onstart, :onlogon, and :onidle schedules don't accept schedule modifiers
  windows_task new_resource.task_name do
    run_level                      :highest
    command                        full_command
    user                           new_resource.user
    password                       new_resource.password
    frequency                      new_resource.frequency.to_sym
    frequency_modifier             new_resource.frequency_modifier if frequency_supports_frequency_modifier?
    start_time                     start_time_value
    start_day                      new_resource.start_date unless new_resource.start_date.nil?
    random_delay                   new_resource.splay if frequency_supports_random_delay?
    disallow_start_if_on_batteries new_resource.splay unless new_resource.run_on_battery || Gem::Requirement.new('< 14.4').satisfied_by?(Gem::Version.new(Chef::VERSION))
    action                         [ :create, :enable ]
  end
end

action :remove do
  windows_task new_resource.task_name do
    action :delete
  end
end

action_class do
  #
  # The full command to run in the scheduled task
  #
  # @return [String]
  #
  def full_command
    # Fetch path of cmd.exe through environment variable comspec
    cmd_path = ENV['COMSPEC']

    "#{cmd_path} /c \"#{client_cmd}\""
  end

  #
  # Build command line to pass to cmd.exe
  #
  # @return [String]
  #
  def client_cmd
    cmd = new_resource.chef_binary_path.dup
    cmd << " -L #{::File.join(new_resource.log_directory, new_resource.log_file_name)}"
    cmd << " -c #{::File.join(new_resource.config_directory, 'client.rb')}"

    # Add custom options
    cmd << " #{new_resource.daemon_options.join(' ')}" if new_resource.daemon_options.any?
    cmd << ' --chef-license accept' if new_resource.accept_chef_license && Gem::Requirement.new('>= 14.12.9').satisfied_by?(Gem::Version.new(Chef::VERSION))
    cmd
  end

  #
  # not all frequencies in the windows_task resource support random_delay
  #
  # @return [boolean]
  #
  def frequency_supports_random_delay?
    %w(once minute hourly daily weekly monthly).include?(new_resource.frequency)
  end

  #
  # not all frequencies in the windows_task resource support frequency_modifier
  #
  # @return [boolean]
  #
  def frequency_supports_frequency_modifier?
    # these are the only ones that don't
    !%w(once on_logon onstart on_idle).include?(new_resource.frequency)
  end

  # @todo this can all get removed when we don't support Chef 13.6 anymore
  def start_time_value
    if new_resource.start_time
      new_resource.start_time
    elsif Gem::Requirement.new('< 13.7.0').satisfied_by?(Gem::Version.new(Chef::VERSION))
      new_resource.frequency == 'minute' ? (Time.now + 60 * new_resource.frequency_modifier.to_f).strftime('%H:%M') : nil
    end
  end
end
