node.override['ohai']['disabled_plugins'] = ['Mdadm']
node.override['ohai']['plugin_path'] = '/tmp/kitchen/ohai/plugins'
node.override['chef_client']['chef_license'] = 'accept-no-persit'
include_recipe 'chef-client::config'
