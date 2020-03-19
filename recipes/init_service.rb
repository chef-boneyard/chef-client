raise 'The chef_client::init_service recipe only supports RHEL / Amazon platform families. All other platforms should run chef-client as a service using systemd or a scheduled job using cron / systemd timers.' unless platform_family?('rhel', 'amazon')

# include helper methods
class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

# libraries/helpers.rb method to DRY directory creation resources
client_bin = find_chef_client
Chef::Log.debug("Using chef-client binary at #{client_bin}")
node.default['chef_client']['bin'] = client_bin
create_chef_directories

template '/etc/init.d/chef-client' do
  source 'redhat/init.d/chef-client.erb'
  mode '0755'
  variables(client_bin: client_bin,
            chkconfig_start_order: node['chef_client']['chkconfig']['start_order'],
            chkconfig_stop_order: node['chef_client']['chkconfig']['stop_order'])
  notifies :restart, 'service[chef-client]', :delayed
end

template '/etc/sysconfig/chef-client' do
  source 'redhat/sysconfig/chef-client.erb'
  mode '0644'
  notifies :restart, 'service[chef-client]', :delayed
end

service 'chef-client' do
  supports status: true, restart: true
  action [:enable, :start]
end
