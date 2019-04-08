# include helper methods
class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

require 'chef/version_constraint'

# libraries/helpers.rb method to DRY directory creation resources
client_bin = find_chef_client
Chef::Log.debug("Using chef-client binary at #{client_bin}")
node.default['chef_client']['bin'] = client_bin

create_chef_directories

file '/Library/LaunchDaemons/com.opscode.chef-client.plist' do
  action :delete
  notifies :stop, 'macosx_service[com.opscode.chef-client]'
end

template '/Library/LaunchDaemons/com.chef.chef-client.plist' do
  source 'com.chef.chef-client.plist.erb'
  mode '0644'
  variables(
    client_bin: client_bin,
    daemon_options: node['chef_client']['daemon_options'],
    interval: node['chef_client']['interval'],
    launchd_mode: node['chef_client']['launchd_mode'],
    log_dir: node['chef_client']['log_dir'],
    log_file: node['chef_client']['log_file'],
    splay: node['chef_client']['splay']
  )
  notifies :restart, 'macosx_service[com.chef.chef-client]'
end

macosx_service 'com.opscode.chef-client' do
  action :nothing
end

macosx_service 'com.chef.chef-client' do
  action :nothing
end

macosx_service 'chef-client' do
  service_name 'com.chef.chef-client'
  plist '/Library/LaunchDaemons/com.chef.chef-client.plist'
  action :start
end
