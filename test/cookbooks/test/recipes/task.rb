node.override['chef_client']['interval'] = 900
node.override['chef_client']['task']['frequency_modifier'] = '31' # this is a string to test that "typo"
node.override['chef_client']['task']['start_date'] = Time.now.strftime('%m/%d/%Y')

include_recipe 'test::config'
include_recipe 'chef-client::task'
include_recipe 'chef-client::delete_validation'

chef_client_scheduled_task 'Chef Client on start' do
  user             node['chef_client']['task']['user']
  password         node['chef_client']['task']['password']
  frequency        'onstart'
  config_directory node['chef_client']['conf_dir']
  log_directory    node['chef_client']['log_dir']
  log_file_name    node['chef_client']['log_file']
  chef_binary_path node['chef_client']['bin']
  daemon_options   node['chef_client']['daemon_options']
  task_name        "#{node['chef_client']['task']['name']}-onstart"
end
