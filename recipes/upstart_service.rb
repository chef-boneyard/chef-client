# include helper methods
class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

# libraries/helpers.rb method to DRY directory creation resources
client_bin = find_chef_client
Chef::Log.debug("Found chef-client in #{client_bin}")
node.default['chef_client']['bin'] = client_bin
create_chef_directories

upstart_job_dir = '/etc/init'
upstart_job_suffix = '.conf'

template "#{upstart_job_dir}/chef-client#{upstart_job_suffix}" do
  source 'debian/init/chef-client.conf.erb'
  mode '644'
  variables(
    client_bin: client_bin
  )
  notifies :restart, 'service[chef-client]', :delayed
end

service 'chef-client' do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end
