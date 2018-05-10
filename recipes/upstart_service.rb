# include helper methods
class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

# libraries/helpers.rb method to DRY directory creation resources
client_bin = find_chef_client
Chef::Log.debug("Using chef-client binary at #{client_bin}")
node.default['chef_client']['bin'] = client_bin
create_chef_directories

# reload the upstart services
execute 'initctl-reload-configuration' do
  command 'initctl reload-configuration'
  action :nothing
end

template '/etc/init/chef-client.conf' do
  source 'debian/init/chef-client.conf.erb'
  mode '0644'
  variables(
    client_bin: client_bin
  )
  notifies :run, 'execute[initctl-reload-configuration]', :immediate
  notifies :restart, 'service[chef-client]', :delayed
end

service 'chef-client' do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end
