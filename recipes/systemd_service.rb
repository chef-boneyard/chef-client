class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

# libraries/helpers.rb method to DRY directory creation resources
client_bin = find_chef_client
Chef::Log.debug("Using chef-client binary at #{client_bin}")
node.default['chef_client']['bin'] = client_bin
create_chef_directories

dist_dir, conf_dir, env_file = value_for_platform_family(
  ['amazon'] => %w(redhat sysconfig chef-client),
  ['fedora'] => %w(fedora sysconfig chef-client),
  ['rhel'] => %w(redhat sysconfig chef-client),
  ['suse'] => %w(redhat sysconfig chef-client),
  ['debian'] => %w(debian default chef-client),
  ['clearlinux'] => %w(clearlinux chef chef-client)
)

timer = node['chef_client']['systemd']['timer']

exec_options = if timer
                 '-c $CONFIG $OPTIONS'
               else
                 '-c $CONFIG -i $INTERVAL -s $SPLAY $OPTIONS'
               end

env_file = template "/etc/#{conf_dir}/#{env_file}" do
  source "default/#{dist_dir}/#{conf_dir}/chef-client.erb"
  mode '0644'
  notifies :restart, 'service[chef-client]', :delayed unless timer
end

directory '/etc/systemd/system' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

service_unit_content = {
  'Unit' => {
    'Description' => 'Chef Infra Client',
    'After' => 'network.target auditd.service',
  },
  'Service' => {
    'Type' => timer ? 'oneshot' : 'simple',
    'EnvironmentFile' => env_file.path,
    'ExecStart' => "#{client_bin} #{exec_options}",
    'ExecReload' => '/bin/kill -HUP $MAINPID',
    'SuccessExitStatus' => 3,
    'Restart' => node['chef_client']['systemd']['restart'],
  },
  'Install' => { 'WantedBy' => 'multi-user.target' },
}

# add "daemon to the description when we're creating a timer unit
service_unit_content['Unit']['Description'] << ' daemon' unless timer

service_unit_content['Service'].delete('Restart') if timer

if node['chef_client']['systemd']['timeout']
  service_unit_content['Service']['TimeoutSec'] =
    node['chef_client']['systemd']['timeout']
end

if node['chef_client']['systemd']['killmode']
  service_unit_content['Service']['KillMode'] =
    node['chef_client']['systemd']['killmode']
end

systemd_unit 'chef-client.service' do
  content service_unit_content
  action :create
  notifies(:restart, 'service[chef-client]', :delayed) unless timer
end

systemd_unit 'chef-client.timer' do
  content(
    'Unit' => { 'Description' => 'chef-client periodic run' },
    'Install' => { 'WantedBy' => 'timers.target' },
    'Timer' => {
      'OnBootSec' => '1min',
      'OnUnitInactiveSec' => "#{node['chef_client']['interval']}sec",
      'RandomizedDelaySec' => "#{node['chef_client']['splay']}sec",
    }
  )
  action(timer ? [:create, :enable, :start] : [:stop, :disable, :delete])
  notifies :restart, to_s, :delayed unless timer
end

service 'chef-client' do
  supports status: true, restart: true
  action(timer ? [:disable, :stop] : [:enable, :start])
end
