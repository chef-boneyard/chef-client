# include helper methods
class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

create_chef_directories

template '/Library/LaunchDaemons/com.chef.chef-client.plist' do
  source 'com.chef.chef-client.plist.erb'
  mode '0644'
  variables(
    client_bin: node['chef_client']['bin'] || '/opt/chef/bin/chef-client',
    daemon_options: node['chef_client']['daemon_options'],
    interval: node['chef_client']['interval'],
    launchd_mode: node['chef_client']['launchd_mode'],
    log_dir: node['chef_client']['log_dir'],
    log_file: node['chef_client']['log_file'],
    splay: node['chef_client']['splay'],
    working_dir: node['chef_client']['launchd_working_dir']
  )
  notifies :restart, 'launchd[com.chef.chef-client]' if node['chef_client']['launchd_self-update']
end

launchd 'com.chef.chef-client' do
  path '/Library/LaunchDaemons/com.chef.chef-client.plist'
  action [:create, :enable]
end
