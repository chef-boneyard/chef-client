node.override['ohai']['disabled_plugins'] = ['Mdadm']
node.override['ohai']['plugin_path'] = '/tmp/kitchen/ohai/plugins'

include_recipe 'chef-client::config'

chef_gem 'syslog-logger' do
  compile_time false
end

cookbook_file '/etc/chef/client.d/myconfig.rb' do
  source 'myconfig.rb'
  mode '0644'
  notifies :create, 'ruby_block[reload_client_config]'
end
