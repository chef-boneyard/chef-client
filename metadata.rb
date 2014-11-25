name              'chef-client'
maintainer        'Opscode, Inc.'
maintainer_email  'cookbooks@opscode.com'
license           'Apache 2.0'
description       'Manages client.rb configuration and chef-client service'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '3.9.0'
recipe 'chef-client', 'Includes the service recipe by default.'
recipe 'chef-client::arch_service', 'Configures chef-client as a service on Arch Linux'
recipe 'chef-client::bluepill_service', 'Configures chef-client as a service under Bluepill'
recipe 'chef-client::config', 'Configures the client.rb from a template.'
recipe 'chef-client::cron', 'Runs chef-client as a cron job rather than as a service'
recipe 'chef-client::daemontools_service', 'Configures chef-client as a service under Daemontools'
recipe 'chef-client::delete_validation', 'Deletes validation.pem after client registers'
recipe 'chef-client::runit_service', 'Configures chef-client as a service under Runit'
recipe 'chef-client::service', 'Sets up a client daemon to run periodically'
recipe 'chef-client::smf_service', 'Configures chef-client as a service under SMF'
recipe 'chef-client::task', 'Runs chef-client as a Windows task.'
recipe 'chef-client::upstart_service', 'Configures chef-client as a service under Upstart'
recipe 'chef-client::winsw_service', 'Configures chef-client as a service under Windows WinSW'

%w{ ubuntu debian redhat centos fedora oracle suse freebsd openbsd mac_os_x mac_os_x_server windows aix }.each do |os|
  supports os
end

# Each of these suggested cookbooks are dependencies when using the
# respective $SERVICE_MANAGER_service recipe.
# Foodcritic comments are included in each recipe to ignore
#   FC007: Ensure recipe dependencies are reflected in cookbook metadata
suggests 'bluepill'
suggests 'daemontools'
suggests 'runit'

depends 'cron', '>= 1.2.0'
depends 'logrotate', '>= 1.2.0'
depends 'windows', '~> 1.11'
