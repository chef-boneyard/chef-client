# include helper meth
class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

# libraries/helpers.rb method to DRY directory creation resources
client_bin = find_chef_client
Chef::Log.debug("Found chef-client in #{client_bin}")
node.default['chef_client']['bin'] = client_bin
create_directories

log "You specified service style 'bsd', chef-client service will be turned " \
    "on by default, you need to setup /etc/rc.conf to turn if off manually."

template '/etc/rc.d/chef-client' do
  source 'freebsd/rc.d/chef-client.erb'
  mode 0755
  variables :client_bin => client_bin
  notifies :restart, 'service[chef-client]', :delayed
end

service 'chef-client' do
  supports :status => true, :restart => true, :start => true
  action [:enable, :start]
end
