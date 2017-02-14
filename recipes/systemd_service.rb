class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

# libraries/helpers.rb method to DRY directory creation resources
client_bin = find_chef_client
Chef::Log.debug("Found chef-client in #{client_bin}")
node.default['chef_client']['bin'] = client_bin
create_directories

dist_dir, conf_dir, env_file = value_for_platform_family(
  ['fedora'] => ['fedora', 'sysconfig', 'chef-client'],
  ['rhel'] => ['redhat', 'sysconfig', 'chef-client'],
  ['suse'] => ['redhat', 'sysconfig', 'chef-client'],
  ['debian'] => ['debian', 'default', 'chef-client']
)

template '/etc/systemd/system/chef-client.service' do
  source 'systemd/chef-client.service.erb'
  mode '644'
  variables(client_bin: client_bin, sysconfig_file: "/etc/#{conf_dir}/#{env_file}")
  notifies :restart, 'service[chef-client]', :delayed
end

template "/etc/#{conf_dir}/#{env_file}" do
  source "#{dist_dir}/#{conf_dir}/chef-client.erb"
  mode '644'
  notifies :restart, 'service[chef-client]', :delayed
end

service 'chef-client' do
  supports status: true, restart: true
  action [:enable, :start]
end
