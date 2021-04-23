#
# Author:: Joshua Timberman (<joshua@chef.io>)
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Cookbook::  chef-client
# Attributes:: default
#
# Copyright:: Copyright (c) Chef Software Inc.
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# We only set these by default because this is what comes from `knife
# bootstrap` (the best way to install Chef Client on managed nodes).
#
# Users can add other configuration options through attributes in
# their favorite way (role, 'site' cookbooks, etc).
default['chef_client']['config'] = {
  'chef_server_url' => Chef::Config[:chef_server_url],
  'validation_client_name' => Chef::Config[:validation_client_name],
  'node_name' => Chef::Config[:node_name],
  'verify_api_cert' => true,
}

# Accept the chef license when running the chef service
default['chef_client']['chef_license'] = nil

default['chef_client']['log_file']    = 'client.log'
default['chef_client']['interval']    = '1800'
default['chef_client']['splay']       = '300'
default['chef_client']['conf_dir']    = '/etc/chef'
default['chef_client']['bin']         = '/opt/chef/bin/chef-client'

# Set a sane default log directory location, overriden by specific
# platforms below.
default['chef_client']['log_dir']     = '/var/log/chef'

# If log file is used, default permissions so everyone can read
default['chef_client']['log_perm'] = '640'

# Configuration for chef-client::cron recipe.
default['chef_client']['cron'] = {
  'minute' => '0,30',
  'hour' => '*',
  'weekday' => '*',
  'path' => nil,
  'environment_variables' => nil,
  'log_directory' => nil,
  'log_file' => '/dev/null',
  'append_log' => false,
  'use_cron_d' => false,
  'mailto' => nil,
  'nice_path' => '/bin/nice',
}

# on linux we should use cron_d instead of crontab
default['chef_client']['cron']['use_cron_d'] = true if node['os'] == 'linux'

# Configuration for chef-client::systemd_service recipe
default['chef_client']['systemd']['timer'] = false
# Systemd timeout. Might be useful for timer setups to avoid stalled chef runs
default['chef_client']['systemd']['timeout'] = false
# Restart mode when not running as a timer
default['chef_client']['systemd']['restart'] = 'always'

# Configuration for Windows scheduled task
default['chef_client']['task']['frequency'] = 'minute'
default['chef_client']['task']['frequency_modifier'] = node['chef_client']['interval'].to_i / 60
default['chef_client']['task']['user'] = 'SYSTEM'
default['chef_client']['task']['password'] = nil # Password is only required for non-system users
default['chef_client']['task']['start_time'] = nil
default['chef_client']['task']['start_date'] = nil
default['chef_client']['task']['name'] = 'chef-client'

default['chef_client']['load_gems'] = {}

default['chef_client']['config']['start_handlers'] = []
default['chef_client']['config']['report_handlers'] = []
default['chef_client']['config']['exception_handlers'] = []

# If set to false, changes in the `client.rb` template won't trigger a reload
# of those configs in the current Chef run.
default['chef_client']['reload_config'] = true

# Any additional daemon options can be set as an array. This will be
# join'ed in the relevant service configuration.
default['chef_client']['daemon_options'] = []

# Ohai plugins to be disabled are configured in /etc/chef/client.rb,
# so they can be set as an array in this attribute.
default['ohai']['disabled_plugins'] = []

# Ohai plugins to be enabled are configured in /etc/chef/client.rb,
# so they can be set as an array in this attribute.
default['ohai']['optional_plugins'] = []

# An additional path to load Ohai plugins from.
default['ohai']['plugin_path'] = nil

# Use logrotate_app definition on supported platforms via config recipe
# when chef_client['log_file'] is set.
# Default rotate: 12; frequency: weekly
default['chef_client']['logrotate']['rotate'] = 12
default['chef_client']['logrotate']['frequency'] = 'weekly'

case node['platform_family']
when 'aix'
  default['chef_client']['init_style']  = 'src'
  default['chef_client']['svc_name']    = 'chef'
  default['chef_client']['run_path']    = '/var/run/chef'
  default['chef_client']['file_backup_path'] = '/var/lib/chef'
  default['chef_client']['log_dir']     = '/var/adm/chef'
when 'amazon', 'rhel', 'fedora', 'debian', 'suse', 'clearlinux'
  default['chef_client']['init_style']  = node['init_package']
  default['chef_client']['run_path']    = '/var/run/chef'
  default['chef_client']['file_backup_path'] = '/var/lib/chef'
  default['chef_client']['chkconfig']['start_order'] = 98
  default['chef_client']['chkconfig']['stop_order']  = 02
when 'freebsd'
  default['chef_client']['init_style']  = 'bsd'
  default['chef_client']['run_path']    = '/var/run'
  default['chef_client']['file_backup_path'] = '/var/chef/backup'
# don't use bsd paths per COOK-1379
when 'mac_os_x'
  default['chef_client']['init_style']  = 'launchd'
  default['chef_client']['log_dir']     = '/Library/Logs/Chef'
  # Launchd doesn't use pid files
  default['chef_client']['run_path']    = '/var/run/chef'
  default['chef_client']['file_backup_path'] = '/Library/Caches/Chef/Backup'
  # Set to 'daemon' if you want chef-client to run
  # continuously with the -d and -s options, or leave
  # as 'interval' if you want chef-client to be run
  # periodically by launchd
  default['chef_client']['launchd_mode'] = 'interval'
  default['chef_client']['launchd_working_dir'] = '/var/root'
  default['chef_client']['launchd_self-update'] = false
when 'openindiana', 'opensolaris', 'nexentacore', 'solaris2', 'omnios'
  default['chef_client']['init_style']  = 'smf'
  default['chef_client']['run_path']    = '/var/run/chef'
  default['chef_client']['file_backup_path'] = '/var/chef/backup'
  default['chef_client']['method_dir'] = '/lib/svc/method'
  default['chef_client']['bin_dir'] = '/usr/bin'
  default['chef_client']['locale'] = 'en_US.UTF-8'
  default['chef_client']['env_path'] = '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
when 'smartos'
  default['chef_client']['init_style']  = 'smf'
  default['chef_client']['run_path']    = '/var/run/chef'
  default['chef_client']['file_backup_path'] = '/var/chef/backup'
  default['chef_client']['method_dir'] = '/opt/local/lib/svc/method'
  default['chef_client']['bin_dir'] = '/opt/local/bin'
  default['chef_client']['locale'] = 'en_US.UTF-8'
  default['chef_client']['env_path'] = '/usr/local/sbin:/usr/local/bin:/opt/local/sbin:/opt/local/bin:/usr/sbin:/usr/bin:/sbin'
when 'windows'
  default['chef_client']['init_style']  = 'windows'
  default['chef_client']['conf_dir']    = 'C:/chef'
  default['chef_client']['run_path']    = "#{node['chef_client']['conf_dir']}/run"
  default['chef_client']['file_backup_path'] = "#{node['chef_client']['conf_dir']}/backup"
  default['chef_client']['log_dir']     = "#{node['chef_client']['conf_dir']}/log"
  default['chef_client']['bin']         = 'C:/opscode/chef/bin/chef-client'
else
  default['chef_client']['init_style']  = 'none'
  default['chef_client']['run_path']    = '/var/run'
  default['chef_client']['file_backup_path'] = '/var/chef/backup'
end

# Must appear after init_style to take effect correctly
default['chef_client']['log_rotation']['options'] = ['compress']
default['chef_client']['log_rotation']['prerotate'] = nil
default['chef_client']['log_rotation']['postrotate'] =  case node['chef_client']['init_style']
                                                        when 'systemd'
                                                          node['chef_client']['systemd']['timer'] ? '' : 'systemctl reload chef-client.service >/dev/null || :'
                                                        else
                                                          '/etc/init.d/chef-client reload >/dev/null || :'
                                                        end
