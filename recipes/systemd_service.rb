class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

# libraries/helpers.rb method to DRY directory creation resources
client_bin = find_chef_client
Chef::Log.debug("Found chef-client in #{client_bin}")
node.default['chef_client']['bin'] = client_bin
create_chef_directories

dist_dir, conf_dir, env_file = value_for_platform_family(
  ['amazon'] => ['redhat', 'sysconfig', 'chef-client'],
  ['fedora'] => ['fedora', 'sysconfig', 'chef-client'],
  ['rhel'] => ['redhat', 'sysconfig', 'chef-client'],
  ['suse'] => ['redhat', 'sysconfig', 'chef-client'],
  ['debian'] => ['debian', 'default', 'chef-client']
)

timer = node['chef_client']['systemd']['timer']

exec_options = if timer
                 '-c $CONFIG $OPTIONS'
               else
                 '-c $CONFIG -i $INTERVAL -s $SPLAY $OPTIONS'
               end

template '/etc/systemd/system/chef-client.service' do
  source 'systemd/chef-client.service.erb'
  mode '644'
  variables(
    client_bin: client_bin,
    sysconfig_file: "/etc/#{conf_dir}/#{env_file}",
    type: (timer ? 'oneshot' : 'simple'),
    exec_options: exec_options,
    restart_mode: (timer ? nil : node['chef_client']['systemd']['restart'])
  )
  notifies :restart, 'service[chef-client]', :delayed unless node['chef_client']['systemd']['timer']
end

template "/etc/#{conf_dir}/#{env_file}" do
  source "#{dist_dir}/#{conf_dir}/chef-client.erb"
  mode '644'
  notifies :restart, 'service[chef-client]', :delayed unless node['chef_client']['systemd']['timer']
end

service 'chef-client' do
  supports status: true, restart: true
  if timer
    action [:disable, :stop]
  else
    action [:enable, :start]
  end
end

systemd_unit 'chef-client.timer' do
  content <<-EOH.gsub('^  ', '')
  [Unit]
  Description=chef-client periodic run

  [Install]
  WantedBy=timers.target

  [Timer]
  OnBootSec=1min
  OnUnitActiveSec=#{node['chef_client']['interval']}sec
  # AccuracySec is available on all versions of systemd
  # (whereas RandomizedDelaySec > 229) and will avoid the herd effect
  AccuracySec=#{node['chef_client']['splay']}sec
  EOH
  enabled timer
  if timer
    action [:create, :enable]
  else
    action [:disable, :delete]
  end
end
