node.override['chef_client']['interval'] = 900
node.override['chef_client']['task']['frequency_modifier'] = '31' # this is a string to test that "typo"

include_recipe 'test::config'
include_recipe 'chef-client::task'
include_recipe 'chef-client::delete_validation'
