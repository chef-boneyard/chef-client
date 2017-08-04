node.override['chef_client']['interval'] = 900
incude_recipe 'test::config'
incude_recipe 'chef-client::task'
