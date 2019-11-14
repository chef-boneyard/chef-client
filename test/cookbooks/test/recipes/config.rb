node.override['ohai']['disabled_plugins'] = ['Mdadm']
node.override['ohai']['optional_plugins'] = ['Passwd']
node.override['ohai']['plugin_path'] = '/tmp/kitchen/ohai/plugins'
node.override['chef_client']['chef_license'] = 'accept-no-persist'
include_recipe 'chef-client::config'
