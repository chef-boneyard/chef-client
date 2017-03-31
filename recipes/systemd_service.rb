class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

# libraries/helpers.rb method to DRY directory creation resources
client_bin = find_chef_client
Chef::Log.debug("Found chef-client in #{client_bin}")
node.default['chef_client']['bin'] = client_bin
create_chef_directories

dist_dir, conf_dir = value_for_platform_family(
  ['fedora'] => %w( fedora sysconfig ),
  ['rhel'] => %w( redhat sysconfig ),
  ['suse'] => %w( redhat sysconfig ),
  ['debian'] => %w( debian default )
)

template "/etc/systemd/system/#{node['chef_client']['svc_name']}.service" do
  source 'systemd/chef-client.service.erb'
  mode '644'
  variables(client_bin: client_bin, sysconfig_file: "/etc/#{conf_dir}/#{node['chef_client']['svc_name']}")
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
