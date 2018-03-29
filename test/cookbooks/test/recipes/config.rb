node.override['ohai']['disabled_plugins'] = ['Mdadm']
node.override['ohai']['plugin_path'] = '/tmp/kitchen/ohai/plugins'

include_recipe 'chef-client::config'

chef_gem 'logutils' do
  compile_time false
end

directory Chef::Config[:client_d_dir] do
  recursive true
  owner 'root'
  group 'root'
end

cookbook_file "#{Chef::Config[:client_d_dir]}/myconfig.rb" do
  source 'myconfig.rb'
  mode '0644'
  notifies :create, 'ruby_block[reload_client_config]'
end
