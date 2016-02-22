# include helper methods
class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

# libraries/helpers.rb method to DRY directory creation resources
client_bin = find_chef_client
Chef::Log.debug("Found chef-client in #{client_bin}")
node.default['chef_client']['bin'] = client_bin
create_directories

directory node['chef_client']['method_dir'] do
  action :create
  owner 'root'
  group 'bin'
  mode '0755'
  recursive true
end

local_path = ::File.join(Chef::Config[:file_cache_path], '/')
template "#{node['chef_client']['method_dir']}/chef-client" do
  source 'solaris/chef-client.erb'
  owner 'root'
  group 'root'
  mode '0555'
  notifies :restart, 'service[chef-client]'
end

template(local_path + 'chef-client.xml') do
  if node[:platform_version].to_f >= 5.11
    source 'solaris/manifest-5.11.xml.erb'
  else
    source 'solaris/manifest.xml.erb'
  end
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[load chef-client manifest]', :immediately
end

execute 'load chef-client manifest' do
  action :nothing
  command "svccfg import #{local_path}chef-client.xml"
  notifies :restart, 'service[chef-client]'
end

service 'chef-client' do
  action [:enable, :start]
  provider Chef::Provider::Service::Solaris
end
