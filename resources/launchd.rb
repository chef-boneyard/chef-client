#
# Cookbook:: chef-client
# Resource:: chef_client_launchd
#
# Copyright:: Chef Software, Inc.
#

resource_name :chef_client_launchd
provides :chef_client_launchd

property :user, String,
  default: 'root'

property :working_directory, String,
  default: '/var/root'

property :interval, [Integer, String],
  coerce: proc { |x| Integer(x) },
  callbacks: { 'should be a positive number' => proc { |v| v > 0 } },
  default: 30

property :accept_chef_license, [true, false],
  default: false

property :config_directory, String,
  default: '/etc/chef'

property :log_directory, String,
  default: '/Library/Logs/Chef'

property :log_file_name, String,
  default: 'client.log'

property :chef_binary_path, String,
  default: '/opt/chef/bin/chef-client'

property :daemon_options, Array,
  default: lazy { [] }

property :environment, Hash,
  default: lazy { {} }

property :nice, [Integer, String],
  coerce: proc { |x| Integer(x) },
  callbacks: { 'should be an Integer between -20 and 19' => proc { |v| v >= -20 && v <= 19 } }

property :low_priority_io, [true, false],
  default: true

action :enable do
  unless ::Dir.exist?(new_resource.log_directory)
    directory new_resource.log_directory do
      owner new_resource.user
      mode '0750'
      recursive true
    end
  end

  launchd 'com.chef.chef-client' do
    username new_resource.user
    working_directory new_resource.working_directory
    start_interval new_resource.interval * 60
    program new_resource.chef_binary_path
    program_arguments all_daemon_options
    environment_variables new_resource.environment unless new_resource.environment.empty?
    nice new_resource.nice
    low_priority_io true
    action :enable
  end
end

action :disable do
  service 'chef-client' do
    service_name 'com.chef.chef-client'
    action :disable
  end
end

action_class do
  #
  # Take daemon_options property and append extra daemon options from other properties
  # to build the complete set of options we pass to the client
  #
  # @return [Array]
  #
  def all_daemon_options
    options = new_resource.daemon_options + ['-L', ::File.join(new_resource.log_directory, new_resource.log_file_name), '-c', ::File.join(new_resource.config_directory, 'client.rb')]
    options.append('--chef-license', 'accept') if new_resource.accept_chef_license
    options
  end
end
