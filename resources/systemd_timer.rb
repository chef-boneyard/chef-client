#
# Cookbook:: chef-client
# resource:: chef_client_systemd_timer
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

chef_version_for_provides '< 16.0' if respond_to?(:chef_version_for_provides)

provides :chef_client_systemd_timer
resource_name :chef_client_systemd_timer

property :job_name, String, default: 'chef-client'
property :description, String, default: 'Chef Infra Client periodic execution'

property :user, String, default: 'root'

property :delay_after_boot, String, default: '1min'
property :interval, String, default: '30min'
property :splay, [Integer, String], default: 300,
                                    coerce: proc { |x| Integer(x) },
                                    callbacks: { 'should be a positive number' => proc { |v| v > 0 } }

property :accept_chef_license, [true, false], default: false

property :run_on_battery, [true, false], default: true

property :config_directory, String, default: '/etc/chef'
property :chef_binary_path, String, default: '/opt/chef/bin/chef-client'
property :daemon_options, Array, default: []
property :environment, Hash, default: lazy { {} }

action :add do
  systemd_unit "#{new_resource.job_name}.service" do
    content service_content
    action :create
  end

  systemd_unit "#{new_resource.job_name}.timer" do
    content timer_content
    action [:create, :enable, :start]
  end
end

action :remove do
  systemd_unit "#{new_resource.job_name}.service" do
    action :delete
  end

  systemd_unit "#{new_resource.job_name}.timer" do
    action :delete
  end
end

action_class do
  #
  # The chef-client command to run in the systemd unit.
  #
  # @return [String]
  #
  def chef_client_cmd
    cmd = "#{new_resource.chef_binary_path} "
    cmd << "#{new_resource.daemon_options.join(' ')} " unless new_resource.daemon_options.empty?
    cmd << '--chef-license accept ' if new_resource.accept_chef_license && Gem::Requirement.new('>= 14.12.9').satisfied_by?(Gem::Version.new(Chef::VERSION))
    cmd << "-c #{::File.join(new_resource.config_directory, 'client.rb')} "
    cmd
  end

  #
  # The timer content to pass to the systemd_unit
  #
  # @return [Hash]
  #
  def timer_content
    {
    'Unit' => { 'Description' => new_resource.description },
    'Timer' => {
      'OnBootSec' => new_resource.delay_after_boot,
      'OnUnitActiveSec' => new_resource.interval,
      'RandomizedDelaySec' => new_resource.splay,
      },
    'Install' => { 'WantedBy' => 'timers.target' },
    }
  end

  #
  # The service content to pass to the systemd_unit
  #
  # @return [Hash]
  #
  def service_content
    unit = {
      'Unit' => {
        'Description' => new_resource.description,
        'After' => 'network.target auditd.service',
      },
      'Service' => {
        'Type' => 'oneshot',
        'ExecStart' => chef_client_cmd,
        'SuccessExitStatus' => [3, 213, 35, 37, 41],
      },
      'Install' => { 'WantedBy' => 'multi-user.target' },
    }

    unit['Service']['ConditionACPower'] = 'true' unless new_resource.run_on_battery
    unit['Service']['Environment'] = new_resource.environment.collect { |k, v| "\"#{k}=#{v}\"" } unless new_resource.environment.empty?
    unit
  end
end
