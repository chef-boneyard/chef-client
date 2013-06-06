Description
===========

This cookbook is used to configure a system as a Chef Client.

Requirements
============

Chef 0.10.10 and Ohai 0.6.12 are required due to the use of
`platform_family`.

Platforms
---------

The following platforms are supported by this cookbook, meaning that the recipes run on these platforms without error.

* Debian family (Debian, Ubuntu etc)
* Red Hat family (Redhat, CentOS, Oracle etc)
* Fedora family
* SUSE distributions (OpenSUSE, SLES, etc)
* ArchLinux
* FreeBSD
* Mac OS X
* Mac OS X Server

Opscode Cookbooks
-----------------

Some cookbooks can be used with this cookbook but they are not explicitly required. The default settings in this cookbook do not require their use.  The cron cookbook is only needed for the cron recipe if `node["chef_client"]["cron"]["use_cron_d"]` is set to true (it's false by default). The other cookbooks (on community.opsocde.com) are:

* bluepill
* daemontools
* runit
* cron

See __USAGE__ below.

Attributes
==========

* `node["chef_client"]["interval"]` - Sets `Chef::Config[:interval]` via command-line option for number of seconds between chef-client daemon runs. Default 1800.
* `node["chef_client"]["splay"]` - Sets `Chef::Config[:splay]` via command-line option for a random amount of seconds to add to interval. Default 20.
* `node["chef_client"]["log_dir"]` - Sets directory used in `Chef::Config[:log_location]` via command-line option to a location where chef-client should log output. Default "/var/log/chef".
* `node["chef_client"]["conf_dir"]` - Sets directory used via command-line option to a location where chef-client search for the client config file . Default "/etc/chef".
* `node["chef_client"]["bin"]` - Sets the full path to the `chef-client` binary.  Mainly used to set a specific path if multiple versions of chef-client exist on a system or the bin has been installed in a non-sane path. Default "/usr/bin/chef-client".
* `node["chef_client"]["server_url"]` - Sets `Chef::Config[:chef_server_url]` in the config file to the Chef Server URI. Default "http://localhost:4000". See __USAGE__.
* `node["chef_client"]["validation_client_name"]` - Sets `Chef::Config[:validation_client_name]` in the config file to the name of the validation client. Default "chef-validator". See __USAGE__.
* `node["chef_client"]["init_style"]` - Sets up the client service based on the style of init system to use. Default is based on platform and falls back to "none". See __USAGE__.
* `node["chef_client"]["run_path"]` - Directory location where chef-client should write the PID file. Default based on platform, falls back to "/var/run".
* `node["chef_client"]["cache_path"]` - Directory location for `Chef::Config[:file_cache_path]` where chef-client will cache various files. Default is based on platform, falls back to "/var/chef/cache".
* `node["chef_client"]["backup_path"]` - Directory location for `Chef::Config[:file_backup_path]` where chef-client will backup templates and cookbook files. Default is based on platform, falls back to "/var/chef/backup".
* `node["chef_client"]["cron"]["minute"]` - The hour that chef-client will run as a cron task, only applicable if the you set "cron" as the "init_style"
* `node["chef_client"]["cron"]["hour"]` - The hour that chef-client will run as a cron task, only applicable if the you set "cron" as the "init_style"
* `node["chef_client"]["cron"]["environment_variables"]` - Environment variables to pass to chef-client's execution (e.g. SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt chef-client)
* `node["chef_client"]["cron"]["log_file"]` - Location to capture the chef-client output.
* `node["chef_client"]["cron"]["use_cron_d"]` - If true, use the "cron_d" LWRP (https://github.com/opscode-cookbooks/cron). If false (default), use the cron resource built-in to Chef.
* `node["chef_client"]["load_gems"]` - Hash of gems to load into chef via the client.rb file
* `node["chef_client"]["report_handlers"]` - Array of Hashes that contain a class and arguments element appended in the client.rb file. ex: `{:class => "MyHandler", :arguments => [true]}
* `node["chef_client"]["exception_handlers"]` - Array of Hashes that contain a class and arguments element appended in the client.rb file. ex: `{:class => "MyHandler", :arguments => [true]}
* `node["chef_client"]["checksum_cache_skip_expires"]` - true or false value used in the `cache_options` section of the client.rb file.
* `node["chef_client"]["checksum_cache_path"]` -  file system path used in the `cache_options` section of the client.rb file.
* `node["chef_client"]["launchd_mode"]` - (Only for Mac OS X) if set to "daemon", runs chef-client with `-d` and `-s` options; defaults to "interval"
* `node["chef_client"]["daemon_options"]` - An array of additional options to pass to the chef-client service, empty by default, and must be an array if specified.
* `node["ohai"]["disabled_plugins"]` - An array of ohai plugins to disable, empty by default, and must be an array if specified.

Recipes
=======

This section describes the recipes in the cookbook and how to use them in your environment.

config
------

Sets up the `/etc/chef/client.rb` config file from a template and reloads the configuration for the current chef-client run.

service
-------

Use this recipe on systems that should have a `chef-client` daemon running, such as when Knife bootstrap was used to install Chef on a new system.

This recipe sets up the `chef-client` service depending on the `init_style` attribute (see above). The following init styles are supported:

* init - uses the init script included in the chef gem, supported on debian and redhat family distributions.
* upstart - uses the upstart job included in the chef gem, supported on ubuntu.
* arch - uses the init script included in this cookbook for ArchLinux, supported on arch.
* runit - sets up the service under runit, supported on ubuntu, debian and gentoo.
* bluepill - sets up the service under bluepill. As bluepill is a pure ruby process monitor, this should work on any platform.
* daemontools - sets up the service under daemontools, supported on debian, ubuntu and arch
* launchd - sets up the service under launchd, supported on Mac OS X & Mac OS X Server. (this requires Chef >= 0.10.10)
* bsd - prints a message about how to update BSD systems to enable the chef-client service, supported on Free/OpenBSD.

default
-------

Includes the `chef-client::service` recipe by default.

delete_validation
-----------------

Use this recipe to delete the validation certificate (default `/etc/chef/validation.pem`) when using a `chef-client` after the client has been validated and authorized to connect to the server.

Beware if using this on your Chef Server. First copy the validation.pem certificate file to another location, such as your knife configuration directory (`~/.chef`) or [Chef Repository](http://wiki.opscode.com/display/chef/Chef+Repository).

cron
----

Use this recipe to run chef-client as a cron job rather than as a
service. The cron job runs after random delay that is between 0 and 90
seconds to ensure that the chef-clients don't attempt to connect to
the chef-server at the exact same time. You should set
node["chef_client"]["init_style"] = "none" when you use this mode but
it is not required.

USAGE
=====

Create a `base` role that will represent the base configuration for any system that includes managing aspects of the chef-client. Add recipes to the run list of the role, customize the attributes, and apply the role to nodes. For example, the following role (Ruby DSL) will set the init style to `init`, delete the validation certificate (as the client would already be authenticated) and set up the chef-client as a service using the init style.

    name "base"
    description "Base role applied to all nodes"
    override_attributes(
      "chef_client" => {
        "init_style" => "init"
      }
    )
    run_list(
      "recipe[chef-client::delete_validation]",
      "recipe[chef-client::config]",
      "recipe[chef-client::service]"
    )

The `chef-client::config` recipe is only required with init style `init` (default setting for the attribute on debian/redhat family platforms, because the init script doesn't include the `pid_file` option which is set in the config.

The default Chef Server will be `http://localhost:4000` which is the `Chef::Config[:chef_server_url]` default value. To use the config recipe with the Opscode Platform, for example, add the following to the `override_attributes`

    override_attributes(
      "chef_client" => {
        "server_url" => "https://api.opscode.com/organizations/ORGNAME",
        "validation_client_name" => "ORGNAME-validator"
      }
    )

Where ORGNAME is your Opscode Platform organization name. Be sure to add these attributes to the role if modifying per the section below.

You can also set all of the `Chef::Config` http proxy related settings.  By default Chef will not use a proxy.

    override_attributes(
      "chef_client" => {
        "http_proxy" => "http://proxy.vmware.com:3128",
        "https_proxy" => "http://proxy.vmware.com:3128",
        "http_proxy_user" => "my_username",
        "http_proxy_pass" => "Awe_some_Pass_Word!",
        "no_proxy" => "*.vmware.com,10.*"
      }
    )

Alternate Init Styles
---------------------

The alternate init styles available are:

* runit
* bluepill
* daemontools
* none -- should be specified if you are running chef-client as cron job

For usage, see below.

# Runit

To use runit, download the cookbook from the cookbook site.

    knife cookbook site vendor runit -d

Change the `init_style` to runit in the base role and add the runit recipe to the role's run list:

    name "base"
    description "Base role applied to all nodes"
    override_attributes(
      "chef_client" => {
        "init_style" => "runit"
      }
    )
    run_list(
      "recipe[chef-client::delete_validation]",
      "recipe[runit]",
      "recipe[chef-client]"
    )

The `chef-client` recipe will create the chef-client service configured with runit. The runit run script will be located in `/etc/sv/chef-client/run`. The output log will be in the runit service directory, `/etc/sv/chef-client/log/main/current`.

# Bluepill

To use bluepill, download the cookbook from the cookbook site.

    knife cookbook site vendor bluepill -d

Change the `init_style` to runit in the base role and add the bluepill recipe to the role's run list:

    name "base"
    description "Base role applied to all nodes"
    override_attributes(
      "chef_client" => {
        "init_style" => "bluepill"
      }
    )
    run_list(
      "recipe[chef-client::delete_validation]",
      "recipe[bluepill]",
      "recipe[chef-client]"
    )

The `chef-client` recipe will create the chef-client service configured with bluepill. The bluepill "pill" will be located in `/etc/bluepill/chef-client.pill`. The output log will be to client.log file in the `node["chef_client"]["log_dir"]` location, `/var/log/chef/client` by default.

# Daemontools

To use daemontools, download the cookbook from the cookbook site.

    knife cookbook site vendor daemontools -d

Change the `init_style` to runit in the base role and add the daemontools recipe to the role's run list:

    name "base"
    description "Base role applied to all nodes"
    override_attributes(
      "chef_client" => {
        "init_style" => "daemontools"
      }
    )
    run_list(
      "recipe[chef-client::delete_validation]",
      "recipe[daemontools]",
      "recipe[chef-client]"
    )

The `chef-client` recipe will create the chef-client service configured under daemontools. It uses the same sv run scripts as the runit recipe. The run script will be located in `/etc/sv/chef-client/run`. The output log will be in the daemontools service directory, `/etc/sv/chef-client/log/main/current`.

# Launchd

On Mac OS X and Mac OS X Server, the default service implementation is "launchd". Launchd support for the service resource is only supported from Chef 0.10.10 onwards.
An error message will be logged if you try to use the launchd service for chef-client on a Chef version that does not contain this launchd support.

Since launchd can run a service in interval mode, by default chef-client is not started in daemon mode like on Debian or Ubuntu. Keep this in mind when you look at your process list and check for a running chef process! If you wish to run chef-client in daemon mode, set attribute `chef_client.launchd_mode` to "daemon".

Templates
=========

chef-client.pill.erb
--------------------

Bluepill configuration for the chef-client service.

client.rb.erb
-------------

Configuration for the client, lands in directory specified by `node["chef_client"]["conf_dir"]` (`/etc/chef/client.rb` by default).

`sv-chef-client-*run.erb`
-------------------------

Runit and Daemontools run script for chef-client service and logs.

Logs will be located in the `node["chef_client"]["log_dir"]`.

com.opscode.chef-client.plist
-----------------------------

Launchd configuration file for chef-client as a true Mac service. The template accepts the `node["chef_client"]["interval"]` value.

License and Author
==================

Author:: Joshua Timberman (<joshua@opscode.com>)
Author:: Seth Chisamore (<schisamo@opscode.com>)
Copyright:: 2010-2012, Opscode, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
