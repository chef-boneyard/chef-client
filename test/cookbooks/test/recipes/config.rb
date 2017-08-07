node.override['ohai']['disabled_plugins'] = ['Mdadm']
node.override['ohai']['plugin_path'] = '/tmp/kitchen/ohai/plugins'
include_recipe 'chef-client::config'
