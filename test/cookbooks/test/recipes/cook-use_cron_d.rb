node.override['chef_client']['cron']['use_cron_d'] = true
apt_update 'update'
include_recipe 'cron::default'
include_recipe 'chef-client::cron'
