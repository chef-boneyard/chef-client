name              'chef-client'
maintainer        'Chef Software, Inc.'
maintainer_email  'cookbooks@chef.io'
license           'Apache-2.0'
description       'Manages client.rb configuration and chef-client service'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '11.0.5'
recipe 'chef-client', 'Includes the service recipe by default.'
recipe 'chef-client::bsd_service', 'Configures chef-client as a service on *BSD'
recipe 'chef-client::config', 'Configures the client.rb from a template.'
recipe 'chef-client::cron', 'Runs chef-client as a cron job rather than as a service'
recipe 'chef-client::delete_validation', 'Deletes validation.pem after client registers'
recipe 'chef-client::init_service', 'Configures chef-client as a SysVInit service'
recipe 'chef-client::launchd_service', 'Configures chef-client as a launchd service on OS X'
recipe 'chef-client::service', 'Sets up a client daemon to run periodically'
recipe 'chef-client::smf_service', 'Configures chef-client as a service under SMF'
recipe 'chef-client::src_service', 'Configures chef-client as a Service Resource Controller service on AIX'
recipe 'chef-client::task', 'Runs chef-client as a Windows task.'
recipe 'chef-client::upstart_service', 'Configures chef-client as a service under Upstart'

%w( aix amazon centos fedora freebsd debian oracle mac_os_x redhat suse opensuse opensuseleap ubuntu windows zlinux ).each do |os|
  supports os
end

depends 'cron', '>= 4.2.0'
depends 'logrotate', '>= 1.9.0'

source_url 'https://github.com/chef-cookbooks/chef-client'
issues_url 'https://github.com/chef-cookbooks/chef-client/issues'
chef_version '>= 13.0'
