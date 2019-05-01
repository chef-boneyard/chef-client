node.override['chef_client']['chef_license'] = 'accept-no-persist'
include_recipe 'chef-client::config'
