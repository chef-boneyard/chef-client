# include helper methods
class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

require 'chef/version_constraint'

# libraries/helpers.rb method to DRY directory creation resources
client_bin = find_chef_client
Chef::Log.debug("Found chef-client in #{client_bin}")
node.default['chef_client']['bin'] = client_bin
create_directories

file '/Library/LaunchDaemons/com.opscode.chef-client.plist' do
  action :delete
  notifies :stop, 'service[com.opscode.chef-client]'
end

template '/Library/LaunchDaemons/com.chef.chef-client.plist' do
  source 'com.chef.chef-client.plist.erb'
  mode '644'
  variables(
    launchd_mode: node['chef_client']['launchd_mode'],
    client_bin: client_bin
  )
end

service 'com.opscode.chef-client' do
  action :nothing
end

service 'chef-client' do
  service_name 'com.chef.chef-client'
  provider Chef::Provider::Service::Macosx
  action :start
end
