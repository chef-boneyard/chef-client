include_attribute "chef-client::install"

default['chef-client']['omnibus']['version'] = node['chef-client']['version']
default['chef-client']['omnibus']['prereleases'] = false
default['chef-client']['omnibus']['nightlies'] = false
default['chef-client']['omnibus']['package_file'] = nil
default['chef-client']['omnibus']['package_checksum'] = nil
