#
# Cookbook:: chef-client
# resource:: chef_client_cron
#
# Copyright:: 2020, Chef Software, Inc.
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

resource_name :chef_client_cron

property :user, String, default: 'root'

property :minute, [String, Integer], default: '0,30'
property :hour, [String, Integer], default: '*'
property :day, [Integer, String], default: '*'
property :month, [Integer, String], default: '*'
property :weekday, [String, Integer], default: '*'
property :mailto, String

property :job_name, String, default: 'chef-client'
property :splay, [Integer, String], default: 300,
                                    coerce: proc { |x| Integer(x) },
                                    callbacks: { 'should be a positive number' => proc { |v| v > 0 } }

property :environment, Hash, default: lazy { {} }

property :comment, String

property :config_directory, String, default: '/etc/chef'
property :log_directory, String, default: lazy { platform?('mac_os_x') ? '/Library/Logs/Chef' : '/var/log/chef' }
property :log_file_name, String, default: 'client.log'
property :append_log_file, [true, false], default: true
property :chef_binary_path, String, default: '/opt/chef/bin/chef-client'
property :daemon_options, Array, default: []

action :add do
  unless ::Dir.exist?(new_resource.log_directory)
    directory new_resource.log_directory do
      owner new_resource.user
      mode '0640'
      recursive true
    end
  end

  cron_d new_resource.job_name do
    minute      new_resource.minute
    hour        new_resource.hour
    day         new_resource.day
    weekday     new_resource.weekday
    month       new_resource.month
    environment new_resource.environment
    mailto      new_resource.mailto if new_resource.mailto
    user        new_resource.user
    comment     new_resource.comment if new_resource.comment
    command     cron_command
  end
end

action :remove do
  cron_d new_resource.job_name do
    action :delete
  end
end

action_class do
  #
  # The complete cron command to run
  #
  # @return [String]
  #
  def cron_command
    cmd = ''
    cmd << "/bin/sleep #{splay_sleep_time(new_resource.splay)}; "
    cmd << "#{new_resource.chef_binary_path} "
    cmd << "#{new_resource.daemon_options.join(' ')} " unless new_resource.daemon_options.empty?
    cmd << log_command
    cmd << " || echo \"#{Chef::Dist::PRODUCT} execution failed\"" if new_resource.mailto
    cmd
  end

  #
  # The portion of the overall cron job that handles logging based on the append_log_file property
  #
  # @return [String]
  #
  def log_command
    if new_resource.append_log_file
      "-L #{::File.join(new_resource.log_directory, new_resource.log_file_name)}"
    else
      "> #{::File.join(new_resource.log_directory, new_resource.log_file_name)} 2>&1"
    end
  end
end
