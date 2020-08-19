# Chef Client Cookbook

[![Build Status](https://travis-ci.org/chef-cookbooks/chef-client.svg?branch=master)](https://travis-ci.org/chef-cookbooks/chef-client) [![Cookbook Version](https://img.shields.io/cookbook/v/chef-client.svg)](https://supermarket.chef.io/cookbooks/chef-client)

This cookbook is used to configure a system to run the Chef Infra Client.

## Requirements

### Platforms

- AIX 6+
- Clear Linux
- Debian
- Fedora
- FreeBSD
- macOS
- openSUSE
- SLES 12+
- RHEL
- Solaris 10+
- Ubuntu
- Windows

### Chef

- Chef 13.0+

### Cookbooks

- cron 2.0+
- logrotate 1.9.0+

See [USAGE](#usage).


## Resources

The chef-client cookbook provides several resources for setting up Chef Infra Client to run on a schedule. When possible these resources should be used instead of the legacy attributes / recipes as these same resources will be included in Chef Infra Client 16+ out of the box.

### chef_client_scheduled_task

The chef_client_scheduled_task resource setups up Chef Infra Client to run as a scheduled task on Windows. You can use this resource directly in any of your own recipes. Using this resource to configure Chef Infra Client running as a scheduled task allows you to control where you store the user credentials instead of storing them as node attributes. This is useful if you want to store these credentials in an encrypted databag or other secrets store.

### Actions

- `:add`
- `:remove`

### Properties

- `user` - The username to run the task as. default: 'System'
- `password` The password of the user to run the task as if not using the System user
- `frequency` - Frequency with which to run the task (e.g., 'hourly', 'daily', etc.) Default is 'minute'
- `frequency_modifier` Numeric value to go with the scheduled task frequency - default: '30'
- `start_time` The start time for the task in HH:mm format (ex: 14:00). If the `frequency` is `minute` default start time will be `Time.now` plus the `frequency_modifier` number of minutes.
- `start_date` - The start date for the task in `m:d:Y` format (ex: 12/17/2017). nil by default and isn't necessary if you're running a regular interval.
- `splay` - A random number of seconds between 0 and X to add to interval. default: '300'
- `config_directory` - The path to the Chef config directory. default: 'C:/chef'
- `log_file_name` - The name of the log file. default: 'chef-client.log'
- `log_directory` - The path to the Chef log directory. default: 'CONFIG_DIRECTORY/log'
- `chef_binary_path` - The path to the chef-client binary. default: 'C:/opscode/chef/bin/chef-client'
- `daemon_options` - An optional array of extra options to pass to the chef-client
- `task_name` - The name of the scheduled task. This allows for multiple chef_client_scheduled_task resources when it is used directly like in a wrapper cookbook. default: 'chef-client'

### chef_client_cron

The chef_client_cron resource sets up Chef Infra Client to run as a cron job using a cron.d configuration file on Linux hosts or a job in /etc/crontab for other Unix operating systems. You can use this resource directly in any of your own recipes.

### Actions

- `:add`
- `:remove`

### Properties

- `user` - The username to run the task as. default: 'root'
- `minute` - The minute that Chef Infra Client will run as a cron task. default: '0,30' (every 30 minutes)
- `hour` - The hour that Chef Infra Client will run as a cron task. default: '*'
- `day` - The day that Chef Infra Client will run as a cron task. default: '*'
- `month` - The month that Chef Infra Client will run as a cron task. default: '*'
- `weekday` - The weekday that Chef Infra Client will run as a cron task. default: '*'
- `comment` - A comment to add to the cron file.
- `mailto` - The e-mail address to e-mail any cron task failures to.
- `job_name` - The name of the cron task to create. This allows you to have schedules with different options if necessary. default: 'chef-client'
- `splay` - A random number of seconds between 0 and X to add to interval. default: '300'
- `environment` - A hash of environment variables to pass to chef-client's execution (e.g. `SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt chef-client`)
- `config_directory` - The path to the Chef config directory. default: '/etc/chef/'
- `log_file_name` - The name of the log file. default: 'chef-client.log'
- `log_directory` - The path to the Chef log directory. default: '/var/log/chef' on *nix or '/Library/Logs/Chef' on macOS
- `append_log_file` - Whether to append to the log. Default: `true` chef-client output.
- `chef_binary_path` - The path to the chef-client binary. default: '/opt/chef/bin/chef-client'
- `daemon_options` - An optional array of extra command line options to pass to the chef-client

### chef_client_trusted_certificate

The chef_client_trusted_certificate allows you to add a certificate to Chef Infra Client's set of trusted certificates. This is helpful when adding internal certificates for systems that the Chef Infra Client will later need to communicate with using SSL. You can use this resource directly in any of your own recipes.

### Actions

- `:add`
- `:remove`

### Properties

- `cert_name` - The name on disk for the cert file. If not specified the resource name will be used (and .pem appended if necessary)
- `certificate` - The text content of the certificate file

### Examples

```ruby
chef_client_trusted_certificate 'self-signed.badssl.com' do
  certificate <<~CERT
  -----BEGIN CERTIFICATE-----
  MIIDeTCCAmGgAwIBAgIJAPziuikCTox4MA0GCSqGSIb3DQEBCwUAMGIxCzAJBgNV
  BAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMRYwFAYDVQQHDA1TYW4gRnJhbmNp
  c2NvMQ8wDQYDVQQKDAZCYWRTU0wxFTATBgNVBAMMDCouYmFkc3NsLmNvbTAeFw0x
  OTEwMDkyMzQxNTJaFw0yMTEwMDgyMzQxNTJaMGIxCzAJBgNVBAYTAlVTMRMwEQYD
  VQQIDApDYWxpZm9ybmlhMRYwFAYDVQQHDA1TYW4gRnJhbmNpc2NvMQ8wDQYDVQQK
  DAZCYWRTU0wxFTATBgNVBAMMDCouYmFkc3NsLmNvbTCCASIwDQYJKoZIhvcNAQEB
  BQADggEPADCCAQoCggEBAMIE7PiM7gTCs9hQ1XBYzJMY61yoaEmwIrX5lZ6xKyx2
  PmzAS2BMTOqytMAPgLaw+XLJhgL5XEFdEyt/ccRLvOmULlA3pmccYYz2QULFRtMW
  hyefdOsKnRFSJiFzbIRMeVXk0WvoBj1IFVKtsyjbqv9u/2CVSndrOfEk0TG23U3A
  xPxTuW1CrbV8/q71FdIzSOciccfCFHpsKOo3St/qbLVytH5aohbcabFXRNsKEqve
  ww9HdFxBIuGa+RuT5q0iBikusbpJHAwnnqP7i/dAcgCskgjZjFeEU4EFy+b+a1SY
  QCeFxxC7c3DvaRhBB0VVfPlkPz0sw6l865MaTIbRyoUCAwEAAaMyMDAwCQYDVR0T
  BAIwADAjBgNVHREEHDAaggwqLmJhZHNzbC5jb22CCmJhZHNzbC5jb20wDQYJKoZI
  hvcNAQELBQADggEBAGlwCdbPxflZfYOaukZGCaxYK6gpincX4Lla4Ui2WdeQxE95
  w7fChXvP3YkE3UYUE7mupZ0eg4ZILr/A0e7JQDsgIu/SRTUE0domCKgPZ8v99k3A
  vka4LpLK51jHJJK7EFgo3ca2nldd97GM0MU41xHFk8qaK1tWJkfrrfcGwDJ4GQPI
  iLlm6i0yHq1Qg1RypAXJy5dTlRXlCLd8ufWhhiwW0W75Va5AEnJuqpQrKwl3KQVe
  wGj67WWRgLfSr+4QG1mNvCZb2CkjZWmxkGPuoP40/y7Yu5OFqxP5tAjj4YixCYTW
  EVA0pmzIzgBg+JIe3PdRy27T0asgQW/F4TY61Yk=
  -----END CERTIFICATE-----
  CERT
end
```

## Attributes

The following attributes affect the behavior of the chef-client program when running as a service through one of the service recipes, or in cron with the cron recipe, or are used in the recipes for various settings that require flexibility.

- `node['chef_client']['interval']` - Sets `Chef::Config[:interval]` via command-line option for number of seconds between chef-client daemon runs. Default 1800.
- `node['chef_client']['splay']` - Sets `Chef::Config[:splay]` via command-line option for a random amount of seconds to add to interval. On windows, this value is used for the scheduled task's random delay. Default 300.
- `node['chef_client']['log_file']` - Sets the file name used to store chef-client logs. Default "client.log".
- `node['chef_client']['log_dir']` - Sets directory used to store chef-client logs. Default "/var/log/chef".
- `node['chef_client']['log_rotation']['options']` - Set options to logrotation of chef-client log file. Default `['compress']`.
- `node['chef_client']['log_rotation']['prerotate']` - Set prerotate action for chef-client logrotation. Default to `nil`.
- `node['chef_client']['log_rotation']['postrotate']` - Set postrotate action for chef-client logrotation. Default to chef-client service reload depending on init system. It should be empty to skip reloading chef-client service in case if `node['chef_client']['systemd']['timer']` is true.
- `node['chef_client']['conf_dir']` - Sets directory used via command-line option to a location where chef-client search for the client config file . Default "/etc/chef".
- `node['chef_client']['bin']` - Sets the full path to the `chef-client` binary. Mainly used to set a specific path if multiple versions of chef-client exist on a system or the bin has been installed in a non-sane path. Default "/opt/chef/bin/chef-client".
- `node['chef_client']['ca_cert_path']` - Sets the full path to the PEM-encoded certificate trust store used by `chef-client` when daemonized. If not set, [default values](https://docs.chef.io/chef_client_security.html#ssl-cert-file) are used.
- `node['chef_client']['cron']['minute']` - The minute that chef-client will run as a cron task. See [cron recipe](#cron)
- `node['chef_client']['cron']['hour']` - The hour that chef-client will run as a cron task. See [cron recipe](#cron)
- `node['chef_client']['cron']['weekday']` - The weekday that chef-client will run as a cron task. See [cron recipe](#cron)
- `node['chef_client']['cron']['environment_variables']` - Environment variables to pass to chef-client's execution (e.g. `SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt` chef-client)
- `node['chef_client']['cron']['log_file']` - Location to capture the log output of chef-client during the chef run.
- `node['chef_client']['cron']['append_log']` - Whether to append to the log. Default: `false` chef-client output.
- `node['chef_client']['cron']['use_cron_d']` - If true, use the [`cron_d` resource](https://github.com/chef-cookbooks/cron). If false (default), use the cron resource built-in to Chef.
- `node['chef_client']['cron']['mailto']` - If set, `MAILTO` env variable is set for cron definition
- `node['chef_client']['cron']['priority']` - If set, defines the scheduling priority for the `chef-client` process. MUST be a value between -20 and 19\. ONLY applies to \*nix-style operating systems.
- `node['chef_client']['reload_config']` - If true, reload Chef config of current Chef run when `client.rb` template changes (defaults to true)
- `node['chef_client']['daemon_options']` - An array of additional options to pass to the chef-client service, empty by default, and must be an array if specified.
- `node['chef_client']['systemd']['timer']` - If true, uses systemd timer to run chef frequently instead of chef-client daemon mode (defaults to false). This only works on platforms where systemd is installed and used.
- `node['chef_client']['systemd']['timeout']` - If configured, sets the systemd timeout. This might be useful to avoid stalled chef runs in the systemd timer setup.
- `node['chef_client']['systemd']['restart']` - The string to use for systemd `Restart=` value when not running as a timer. Defaults to `always`. Other possible options: `no, on-success, on-failure, on-abnormal, on-watchdog, on-abort`.
- `node['chef_client']['systemd']['killmode']` - If configured, the string to use for the systemd `KillMode=` value. This determines how PIDs spawned by the chef-client process are handled when chef-client PID stops. Options: `control-group, process, mixed, none`. Systemd defaults to `control-group` when this is not specified. More information can be found on the [systemd.kill man page](https://www.freedesktop.org/software/systemd/man/systemd.kill.html).
- `node['chef_client']['task']['frequency']` - Frequency with which to run the `chef-client` scheduled task (e.g., `'hourly'`, `'daily'`, etc.) Default is `'minute'`.
- `node['chef_client']['task']['frequency_modifier']` - Numeric value to go with the scheduled task frequency. Default is `node['chef_client']['interval'].to_i / 60`
- `node['chef_client']['task']['start_time']` - The start time for the task in `HH:mm` format (ex: 14:00). If the `frequency` is `minute` default start time will be `Time.now` plus the `frequency_modifier` number of minutes.
- `node['chef_client']['task']['start_date']` - The start date for the task in `m:d:Y` format (ex: 12/17/2017). nil by default and isn't necessary if you're running a regular interval.
- `node['chef_client']['task']['user']` - The user the scheduled task will run as, defaults to `'SYSTEM'`.
- `node['chef_client']['task']['password']` - The password for the user the scheduled task will run as, defaults to `nil` because the default user, `'SYSTEM'`, does not need a password.
- `node['chef_client']['task']['name']` - The name of the scheduled task, defaults to `chef-client`.

The following attributes are set on a per-platform basis, see the `attributes/default.rb` file for default values.

- `node['chef_client']['init_style']` - Sets up the client service based on the style of init system to use. Default is based on platform and falls back to `'none'`. See [service recipes](#service-recipes).
- `node['chef_client']['run_path']` - Directory location where chef-client should write the PID file. Default based on platform, falls back to "/var/run".
- `node['chef_client']['file_cache_path']` - Directory location for `Chef::Config[:file_cache_path]` where chef-client will cache various files. Default is unset as it causes problems on first chef runs. The default location is typically "/var/cache/cache" but could be different based on the platform. Use this attribute at your own risk.
- `node['chef_client']['file_backup_path']` - Directory location for `Chef::Config[:file_backup_path]` where chef-client will backup templates and cookbook files. Default is based on platform, falls back to "/var/chef/backup".
- `node['chef_client']['file_staging_uses_destdir']` - How file staging (via temporary files) is done. When true, temporary files are created in the directory in which files will reside. When false, temporary files are created under ENV['TMP'].  When set to `:auto` it creates them in the destination directory, and falls back to the ENV['TMP'] directory when that is not possible.  default value: chef-client default.
This cookbook makes use of attribute-driven configuration with this attribute. See [USAGE](#usage) for examples.
- `node['chef_client']['launchd_mode']` - (only for macOS) If set to `'daemon'`, runs chef-client with `-d` and `-s` options; defaults to `'interval'`.
- `node['chef_client']['launchd_working_dir']` - (only for macOS) Sets the working directory for the launchd user (generally `root`); defaults to `/var/root`.
- `node['chef_client']['launchd_self-update']` - (only for macOS) Determines whether chef-client should attempt to `:restart` itself when changes are made to the launchd plist during converge. Note that the [current implementation](https://github.com/chef/chef/blob/129a6f3982218e5eadcd33b272ba738b317bbcae/lib/chef/provider/service/macosx.rb#L128) of `macosx_service` `:restart` unloads the daemon, which stops the current chef-client run and requires an external process to resume the service. Defaults to `false`.
- When `chef_client['log_file']` is set and running on a [logrotate](https://supermarket.chef.io/cookbooks/logrotate) supported platform (debian, rhel, fedora family), use the following attributes to tune log rotation.
  - `node['chef_client']['logrotate']['rotate']` - Number of rotated logs to keep on disk, default 12.
  - `node['chef_client']['logrotate']['frequency']` - How often to rotate chef client logs, default weekly.

- `node['chef_client']['config']` - A hash of Chef::Config keys and their values, rendered dynamically in `/etc/chef/client.rb`.
- `node['chef_client']['load_gems']` - Hash of gems to load into chef via the client.rb file
- `node['ohai']['disabled_plugins']` - An array of ohai plugins to disable, empty by default, and must be an array if specified. Ohai 6 plugins should be specified as a string (ie. "dmi"). Ohai 7+ plugins should be specified as a symbol within quotation marks (ie. ":Passwd").
- `node['ohai']['optional_plugins']` - An array of optional ohai plugins to enable, empty by default, and must be an array if specified. Ohai 6 plugins should be specified as a string (ie. "dmi"). Ohai 7+ plugins should be specified as a symbol within quotation marks (ie. ":Passwd").
- `node['ohai']['plugin_path']` - An additional path to load Ohai plugins from. Necessary if you use the ohai_plugin resource in the Ohai cookbook to install your own ohai plugins.

### Chef Client Config

[For the most current information about Chef Client configuration, read the documentation.](https://docs.chef.io/config_rb_client.html).

- `node['chef_client']['chef_license']` - Set to 'accept' or 'accept-no-persist' to accept the [license](https://docs.chef.io/chef_license.html) before upgrading to Chef 15.
- `node['chef_client']['config']['chef_server_url']` - The URL for the Chef server.
- `node['chef_client']['config']['validation_client_name']` - The name of the chef-validator key that is used by the chef-client to access the Chef server during the initial chef-client run.
- `node['chef_client']['config']['verbose_logging']` - Set the log level. Options: true, nil, and false. When this is set to false, notifications about individual resources being processed are suppressed (and are output at the :info logging level). Setting this to false can be useful when a chef-client is run as a daemon. Default value: nil.
- `node['chef_client']['config']['rubygems_url']` - The location to source rubygems. It can be set to a string or array of strings for URIs to set as rubygems sources. This allows individuals to setup an internal mirror of rubygems for "airgapped" environments. Default value: `https://www.rubygems.org`.

- See [USAGE](#usage) for how to set handlers with the `config` attribute.

## Recipes

This section describes the recipes in the cookbook and how to use them in your environment.

### config

Sets up the `/etc/chef/client.rb` config file from a template and reloads the configuration for the current chef-client run.

See [USAGE](#usage) for more information on how the configuration is rendered with attributes.

### service recipes

The `chef-client::service` recipe includes one of the `chef-client::INIT_STYLE_service` recipes based on the attribute, `node['chef_client']['init_style']`. The individual service recipes can be included directly, too. For example, to use the init scripts, on a node or role's run list:

```
recipe[chef-client::init_service]
```

Use this recipe on systems that should have a `chef-client` daemon running, such as when Knife bootstrap was used to install Chef on a new system.

- `init` - uses the init script included in this cookbook, supported on debian and redhat family distributions.
- `launchd` - sets up the service under launchd, supported on macOS
- `bsd` - prints a message about how to update BSD systems to enable the chef-client service.
- `systemd` - sets up the service under systemd. Supported on systemd based distros.

### default

Includes the `chef-client::service` recipe by default on \*nix platforms and the task recipe for Windows hosts.

### delete_validation

Use this recipe to delete the validation certificate (default `/etc/chef/validation.pem`) when using a `chef-client` after the client has been validated and authorized to connect to the server.

### cron

Use this recipe to run chef-client as a cron job rather than as a service. The cron job runs after random delay that is between 0 and 90 seconds to ensure that the chef-clients don't attempt to connect to the chef-server at the exact same time. You should set `node['chef_client']['init_style'] = 'none'` when you use this mode but it is not required.

### task

Use this recipe to run chef-client on Windows nodes as a scheduled task. Without modifying attributes the scheduled task will run 30 minutes after the recipe runs, with each chef run rescheduling the run 30 minutes in the future. By default the job runs as the system user. The time period between runs can be modified with the `default['chef_client']['task']['frequency_modifier']` attribute and the user can be changed with the `default['chef_client']['task']['user']` and `default['chef_client']['task']['password']` attributes.

## Usage

Use the recipes as described above to configure your systems to run Chef as a service via cron / scheduled task or one of the service management systems supported by the recipes.

The `chef-client::config` recipe is only _required_ with init style `init` (default setting for the attribute on debian/redhat family platforms, because the init script doesn't include the `pid_file` option which is set in the config.

If you wish to accept the [Chef license](https://docs.chef.io/chef_license.html) before upgrading to Chef 15 you must use the `chef-client::config` recipe or set the `chef_license` value in your config manually. See [Accepting the Chef license](https://docs.chef.io/chef_license_accept.html) for more details or other ways to accept the license.

The config recipe is used to dynamically generate the `/etc/chef/client.rb` config file. The template walks all attributes in `node['chef_client']['config']` and writes them out as key:value pairs. The key should be the configuration directive. For example, the following attributes (in a role):

```ruby
default_attributes(
  "chef_client" => {
    "config" => {
      "ssl_verify_mode" => ":verify_peer",
      "client_fork" => true
    }
  }
)
```

will render the following configuration (`/etc/chef/client.rb`):

```ruby
chef_server_url "https://api.chef.io/organizations/MYORG"
validation_client_name "MYORG-validator"
ssl_verify_mode :verify_peer
node_name "config-ubuntu-1204"
client_fork true
```

The `chef_server_url`, `node_name` and `validation_client_name` are set by default in the attributes file from `Chef::Config`. They are presumed to come from the `knife bootstrap` command when setting up a new node for Chef. To set the node name to the default value (the `node['fqdn']` attribute), it can be set false. Be careful when setting this or the Server URL, as those values may already exist.

As another example, to set HTTP proxy configuration settings. By default Chef will not use a proxy.

```ruby
default_attributes(
  "chef_client" => {
    "config" => {
      "http_proxy" => "http://proxy.mycorp.com:3128",
      "https_proxy" => "http://proxy.mycorp.com:3128",
      "http_proxy_user" => "my_username",
      "http_proxy_pass" => "Awe_some_Pass_Word!",
      "no_proxy" => "*.vmware.com,10.*"
    }
  }
)
```

### Special Behavior

Because attributes are strings and the `/etc/chef/client.rb` can use settings that are not string, such as symbols, some configuration attributes have resulting lines with special behavior:

* the `audit_mode`, `log_level`, and `ssl_verify_mode` attributes are converted to symbols. The attribute need not include an initial colon. For example:

```ruby
default_attributes(
  "chef_client" => {
    "config" => {
      "ssl_verify_mode" => ":verify_peer",
      "log_level" => "debug"
    }
  }
)
```

will render the following configuration (`/etc/chef/client.rb`):

```ruby
ssl_verify_mode :verify_peer
log_level :debug
```

* the `log_level` setting can be either a string representing a file path or one of the symbols `STDOUT`, `STDERR`, `:syslog`, and `:win_evt`. If the `log_level` attribute is a string suggestive of one of these symbols, the resulting configuration line will use the symbol. For example,

```ruby
default_attributes(
  "chef_client" => {
    "config" => {
      "log_location" => "STDOUT"
    }
  }
)
```

will render the following configuration (`/etc/chef/client.rb`):

```ruby
log_location STDOUT
```

and

```ruby
default_attributes(
  "chef_client" => {
    "config" => {
      "log_location" => ":syslog"
    }
  }
)
```

will render the following configuration (`/etc/chef/client.rb`):

```ruby
log_location :syslog
```

The strings "syslog" and "win_evt" will become the symbols `:syslog` and `:win_evt` regardless of whether they have an initial colon.

### Configuration Includes

The `/etc/chef/client.rb` file will include all the configuration files in `/etc/chef/client.d/*.rb`. To create custom configuration, simply render a file resource with `file` (and the `content` parameter), `template`, `remote_file`, or `cookbook_file`. For example, in your own cookbook that requires custom Chef client configuration, create the following `cookbook_file` resource:

```ruby
chef_gem 'syslog-logger'

cookbook_file "/etc/chef/client.d/myconfig.rb" do
  source "myconfig.rb"
  mode '0644'
  notifies :create, "ruby_block[reload_client_config]"
end

include_recipe 'chef-client::config'
```

Then create `files/default/myconfig.rb` with the configuration content you want. For example, if you wish to create a configuration to log to syslog:

```ruby
require 'syslog-logger'
require 'syslog'

Logger::Syslog.class_eval do
  attr_accessor :sync, :formatter
end

log_location Chef::Log::Syslog.new('chef-client', ::Syslog::LOG_DAEMON)
```

On Windows:

```ruby
log_location Chef::Log::WinEvt.new
```

### Requiring Gems

Use the `load_gems` attribute to install gems that need to be required in the client.rb. This attribute should be a hash. The gem will also be installed with `chef_gem`. For example, suppose we want to use a Chef Handler Gem, `chef-handler-updated-resources`, which is used in the next heading. Set the attributes, e.g., in a role:

```ruby
default_attributes(
  "chef_client" => {
    "load_gems" => {
      "chef-handler-updated-resources" => {
        "require_name" => "chef/handler/updated_resources",
        "version" => "0.1"
      }
    }
  }
)
```

Each key in `load_gems` is the name of a gem. Each gem hash can have two keys, the `require_name` which is the string that will be `require`'d in `/etc/chef/client.rb`, and `version` which is the version of the gem to install. If the version is not specified, the latest version will be installed.

The above example will render the following in `/etc/chef/client.rb`:

```ruby
["chef/handler/updated_resources"].each do |lib|
  begin
    require lib
  rescue LoadError
    Chef::Log.warn "Failed to load #{lib}. This should be resolved after a chef run."
  end
end
```

### Start, Report, Exception Handlers

To dynamically render configuration for Start, Report, or Exception handlers, set the following attributes in the `config` attributes:

- `start_handlers`
- `report_handlers`
- `exception_handlers`

This is an alternative to using the [`chef_handler` cookbook](https://supermarket.chef.io/cookbooks/chef_handler).

Each of these attributes must be an array of hashes. The hash has two keys, `class` (a string), and `arguments` (an array). For example, to use the report handler in the [Requiring Gems](#requiring-gems) section:

```ruby
default_attributes(
  "chef_client" => {
    "config" => {
      "report_handlers" => [
        {"class" => "SimpleReport::UpdatedResources", "arguments" => []}
      ]
    }
  }
)
```

If the handler you're using has an initialize method that takes arguments, then pass each one as a member of the array. Otherwise, leave it blank as above.

This will render the following in `/etc/chef/client.rb`.

```ruby
report_handlers << SimpleReport::UpdatedResources.new()
```

#### Launchd

On macOS and macOS Server, the default service implementation is "launchd".

Since launchd can run a service in interval mode, by default chef-client is not started in daemon mode like on Debian or Ubuntu. Keep this in mind when you look at your process list and check for a running chef process! If you wish to run chef-client in daemon mode, set attribute `chef_client.launchd_mode` to "daemon".

## Installing and updating chef-client

This cookbook does not handle updating the chef-client, as that's out of the cookbook's current scope. To sensibly manage updates of the chef-client's install, we refer you to:

- [chef_client_updater](https://github.com/chef-cookbooks/chef_client_updater) - Cookbook for keeping your install up-to-date

## License

**Copyright:** 2010-2020, Chef Software, Inc.

```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
