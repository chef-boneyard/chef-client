#
# Cookbook:: chef-client
# Resource:: chef_client_launchd
#
# Copyright:: Chef Software, Inc.
#

chef_version_for_provides '< 16.5' if respond_to?(:chef_version_for_provides)

resource_name :chef_client_launchd
provides :chef_client_launchd

unified_mode true if respond_to?(:unified_mode)

property :user, String,
  default: 'root'

property :working_directory, String,
  default: '/var/root'

property :interval, [Integer, String],
  coerce: proc { |x| Integer(x) },
  callbacks: { 'should be a positive number' => proc { |v| v > 0 } },
  default: 30

property :splay, [Integer, String],
  default: 300,
  coerce: proc { |x| Integer(x) },
  callbacks: { 'should be a positive number' => proc { |v| v > 0 } }
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
    program_arguments ['/bin/bash', '-c', client_command]
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
  # Generate a uniformly distributed unique number to sleep from 0 to the splay time
  #
  # @param [Integer] splay The number of seconds to splay
  #
  # @return [Integer]
  #
  def splay_sleep_time(splay)
    seed = node['shard_seed'] || Digest::MD5.hexdigest(node.name).to_s.hex
    random = Random.new(seed.to_i)
    random.rand(splay)
  end

  #
  # random sleep time + chef-client + daemon option properties + license acceptance
  #
  # @return [String]
  #
  def client_command
    cmd = ''
    cmd << "/bin/sleep #{splay_sleep_time(new_resource.splay)};"
    cmd << " #{new_resource.chef_binary_path}"
    cmd << " #{new_resource.daemon_options.join(' ')}" unless new_resource.daemon_options.empty?
    cmd << " -c #{::File.join(new_resource.config_directory, 'client.rb')}"
    cmd << " -L #{::File.join(new_resource.log_directory, new_resource.log_file_name)}"
    cmd << ' --chef-license accept' if new_resource.accept_chef_license
    cmd
  end
end
