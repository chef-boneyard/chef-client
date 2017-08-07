node.override['chef_client']['interval'] = 900
include_recipe 'test::config'
include_recipe 'chef-client::task'
