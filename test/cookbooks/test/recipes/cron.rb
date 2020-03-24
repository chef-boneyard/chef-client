apt_update 'update'
include_recipe 'test::config'
include_recipe 'cron::default'
package 'crontabs' if platform?('fedora') # ensures we actually have the /etc/cron.d dir
include_recipe 'chef-client::cron'
include_recipe 'chef-client::delete_validation'
