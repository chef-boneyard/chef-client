# include helper methods
class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

# libraries/helpers.rb method to DRY directory creation resources
client_bin = find_chef_client
Chef::Log.debug("Found chef-client in #{client_bin}")
node.default['chef_client']['bin'] = client_bin
create_chef_directories

dist_dir, conf_dir = value_for_platform_family(
  ['debian'] => %w( debian default ),
  ['fedora'] => %w( redhat sysconfig ),
  ['rhel'] => %w( redhat sysconfig ),
  ['suse'] => %w( suse sysconfig )
)

template "/etc/init.d/#{node['chef_client']['svc_name']}" do
  source "#{dist_dir}/init.d/chef-client.erb"
  mode '755'
  variables client_bin: client_bin
  notifies :restart, 'service[chef-client]', :delayed
end

template "/etc/#{conf_dir}/#{node['chef_client']['svc_name']}" do
  source "#{dist_dir}/#{conf_dir}/chef-client.erb"
  mode '644'
  notifies :restart, 'service[chef-client]', :delayed
end

service 'chef-client' do
  service_name node['chef_client']['svc_name']
  supports status: true, restart: true
  action [:enable, :start]
end
