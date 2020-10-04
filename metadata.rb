name              'chef-client'
maintainer        'Chef Software, Inc.'
maintainer_email  'cookbooks@chef.io'
license           'Apache-2.0'
description       'Manages client.rb configuration and chef-client service'
version           '12.3.2'

%w( aix amazon centos fedora freebsd debian oracle mac_os_x redhat suse opensuseleap ubuntu windows zlinux ).each do |os|
  supports os
end

depends 'cron', '>= 4.2.0'
depends 'logrotate', '>= 1.9.0'

source_url 'https://github.com/chef-cookbooks/chef-client'
issues_url 'https://github.com/chef-cookbooks/chef-client/issues'
chef_version '>= 13.0'
