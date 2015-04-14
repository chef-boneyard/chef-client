v4.3.0 (2015-04-14)
-------------------
- [#303] cron ignores daemon_options
- [#297] support prerotate options in logrotate
- [#296] Support adding audit_mode as configuration in client.rb
- [#295] Add support for specifying gem source for config
- [#294] Cleanup opscode-named plist and service on OS X
- [#291] Pass $OPTIONS to systemd service
- [#289] Use systemd on Debian 8 (jessie)
- [#286] Remove legacy logic for handling Chef Server
- [#283] Update plist filename for new company
- [#278] Fix path on SmartOS
- [#277] Update contributing documentation
- [#275] Correct logrotate postrotate command for upstart init_style
- [#273] Fix punctuation, capitalization and wording in readme
- [#272] Fix readme quoting
- [#271] Add internal heading links to documentation
- [#270] Fix Travis CI build
- [#262] Allow client.rb to contain environment
- [#257] Change log directory mode 0755
- [#254] Remove rbconfig
- [#156] Allow cron to have a weekday parameter

v4.2.4 (2015-02-18)
-------------------
- Ripping out chef_gem compile_time stuff

v4.2.3 (2015-02-18)
-------------------
- Fixing chef_gem with Chef::Resource::ChefGem.method_defined?(:compile_time)

v4.2.2 (2015-02-18)
-------------------
- Fixing chef_gem for Chef below 12.1.0

v4.2.1 (2015-02-17)
-------------------
- Being explicit about usage of the chef_gem's compile_time property.
- Eliminating future deprecation warnings in Chef 12.1.0.

v4.2.0 (2015-02-08)
-------------------
- [#252] Fix ordering problem with logrotate command attribute
- [#250] Verify API certificates by default in config
- [#238] Remove proxy ENV variables from config
- [#234] Move windows service log directory to correct location

v4.1.1 (2015-01-30)
-------------------
- Repair syntax error introduced in config recipe

v4.1.0 (2015-01-30)
-------------------
- [#247] Switch Arch Linux to use systemd
- [#243] Improve logrotation configurability
- [#241] Configure logrotate to use systemd when appropriate
- [#239] Allow setting splay in upstart configuration
- [#233] Unbreak unit and integration test harnesses
- [#231] Allow setting NO_PROXY/no_proxy in client.rb
- [#219] Configure log location via client.rb only

v4.0.0 (2014-12-10)
-------------------
- [#221] Retire the winsw service wrapper in Windows
- [#227] Add sourcing /etc/default/locale to upstart script
- [#224] Fix FreeBSD service startup
- [#223] Add FreeBSD test harness
- [#217] Fix and modernize systemd configuration

v3.9.0 (2014-10-15)
-------------------
- [#208] Add AIX support

v3.8.2 (2014-09-30)
-------------------
- [#206] Fixes amazon linux issues introduced in #190

v3.8.1 (2014-09-30)
-------------------
- [#202] Avoid resource cloning
- [#190] Use systemd by default on EL7

v3.8.0 (2014-09-05)
-------------------
- [#182] Complete refactor of testing. Now uses chefspec and serverspec
- [#134] Update of README to reflect there not being an init recipe
- [#133] Allow windows_task[chef-client] attributes to be overridden
- [#143] Added rc.d script for FreeBSD
- [#155] Allow option to not reload current run Chef config
- [#162] Update cron.rb to work properly for SUSE
- [#169] Sort config hash
- [#184] Changelog fixes

v3.7.0 (2014-08-13)
-------------------
* remove dependency on ruby-wmi which breaks chef 11.14.2

v3.6.0 (2014-06-07)
-------------------
* [COOK-3465] Switch Fedora to using systemd


v3.5.0 (2014-05-07)
-------------------
- [COOK-4594] - 'Found chef-client in' log resource
- Add Windows support to README


v3.4.0 (2014-04-09)
-------------------
- [COOK-4521] - support Ohai 7 syntax for disabling plugins
- [COOK-4505] - kill -9 chef-client when stopping via SMF


v3.3.8 (2014-03-18)
-------------------
- [COOK-4430] can't rotate chef-client's logs


v3.3.6 (2014-03-18)
-------------------
- [COOK-4432] Use SSL verification by default when talking to HEC


v3.3.4 (2014-03-12)
-------------------
- [COOK-4101] - Support ENV['https_proxy']


v3.3.3 (2014-02-27)
-------------------
[COOK-4338] - chef-client Upstart job starts too early


v3.3.2 (2014-02-25)
-------------------
Fixing merge conflict in launchd_service


v3.3.0 (2014-02-25)
-------------------
### Bug
- **[COOK-4286](https://tickets.chef.io/browse/COOK-4286)** - Cleanup the Kitchen
- **[COOK-4242](https://tickets.chef.io/browse/COOK-4242)** - Add Fedora 19 support to chef-client::cron
- **[COOK-4151](https://tickets.chef.io/browse/COOK-4151)** - Runit should set locale
- **[COOK-4127](https://tickets.chef.io/browse/COOK-4127)** - add mailto support for cron runs
- **[COOK-4038](https://tickets.chef.io/browse/COOK-4038)** - Don't define CHEF_SERVER_USER constant if already defined

### New Feature
- **[COOK-4169](https://tickets.chef.io/browse/COOK-4169)** - Add the possibility to specify "options" for the required-gems installation procedure in the chef-client cookbook

### Improvement
- **[COOK-4159](https://tickets.chef.io/browse/COOK-4159)** - turn down "Found chef-client in #{client_bin}" messages to :debug level
- **[COOK-3896](https://tickets.chef.io/browse/COOK-3896)** - launchd_service recipe should use Gem::Requirement instead of Chef::VersionConstraint


v3.2.2 (2014-01-26)
-------------------
[COOK-4092] Add KeepAlive so that launchd will "daemonize" chef-client


v3.2.0
------
### Bug
- **[COOK-3885](https://tickets.chef.io/browse/COOK-3885)** - launchd_service template missing client_bin
- **[COOK-3874](https://tickets.chef.io/browse/COOK-3874)** - COOK-3492 patch breaks server_test.rb
- **[COOK-3848](https://tickets.chef.io/browse/COOK-3848)** - allow disable splay
- Fixing up style to pass most rubocops
- Updating test-kitchen harness


v3.1.2
------
### Bug
- **[COOK-4113](https://tickets.chef.io/browse/COOK-4113)** - chef-client::smf_service breaks permissions on /lib/svc/method

v3.1.0
------
### Bug
- **[COOK-3638](https://tickets.chef.io/browse/COOK-3638)** - Use standard posix shell `/bin/sh` instead of `/bin/bash`
- **[COOK-3637](https://tickets.chef.io/browse/COOK-3637)** - Fix typo in README
- **[COOK-3501](https://tickets.chef.io/browse/COOK-3501)** - Notify reload `:immediately` when `client.rb` template is changed
- **[COOK-3492](https://tickets.chef.io/browse/COOK-3492)** - Test upstart on CentOS

### New Feature
- **[COOK-3500](https://tickets.chef.io/browse/COOK-3500)** - Rotate logs on supported platforms if 'log_file' is set

### Improvement
- **[COOK-1863](https://tickets.chef.io/browse/COOK-1863)** - Install chef-client as a Windows Service

v3.0.6
------
### Bug
- **[COOK-3373](https://tickets.chef.io/browse/COOK-3373)** - Provide full syslog custom config example in README
- **[COOK-3301](https://tickets.chef.io/browse/COOK-3301)** - Fix MiniTest Cron Recipe
- **[COOK-3300](https://tickets.chef.io/browse/COOK-3300)** - Allow environment variables (not require)
- **[COOK-3276](https://tickets.chef.io/browse/COOK-3276)** - Use `node.default` instead of `node.set`
- **[COOK-3227](https://tickets.chef.io/browse/COOK-3227)** - Fix misnamed attribute
- **[COOK-3104](https://tickets.chef.io/browse/COOK-3104)** - Update `.kitchen.yml` to properly set environment_variables

v3.0.4
------
### Bug
- [COOK-3159]: don't skip directory creation on Windows

v3.0.2
------
### Bug
- [COOK-3157]: correct root group detection for Windows

v3.0.0
------
### Sub-task
- [COOK-1002]: chef-client service is not started for `init_style` = init
- [COOK-1191]: chef-client cookbook doesn't log to /var/log/chef/client.log when using `init_style` runit
- [COOK-2319]: The service recipe has too many lines of code
- [COOK-2344]: chef-client config should preserve log settings
- [COOK-2651]: The cron task fails to disable and stop service if the init_style is set to upstart
- [COOK-2709]: chef-client needs explicit dependancy on cron >= 1.2.0
- [COOK-2856]: Use attribute/data driven configuration for /etc/chef/client.rb
- [COOK-2857]: Update chef-client to use runit v1.0+
- [COOK-2858]: support "inclusion" of other Chef Config files in client.rb
- [COOK-3110]: kitchen.yml missing chef-client::config in cook-2317 runlist
- [COOK-3112]: `chef_client` test cook-1951 fails as provided

### Bug
- [COOK-2607]: detect if node is a chef-server and set user/group file ownership correctly
- [COOK-3104]: kitchen.yml file for chef-client doesn't properly set `environment_variables`

### Improvement
- [COOK-2637]: Silence expected errors from which based chef-server checks
- [COOK-2825]: SMF for chef-client should use :kill to stop service

v2.2.4
------
### Bug
- [COOK-2687]: chef-client::service doesn't work on SLES 11
- [COOK-2689]: chef-client service recipe on windows fails to start
- [COOK-2700]: chef-client cookbook should have more splay
- [COOK-2952]: chef-client cookbook has foodcritic failures

### Sub-task
- [COOK-2823]: Chef-client SMF manifest should set locale to UTF-8

v2.2.2
------
- [COOK-2393] - chef-client::delete_validation checks for chef-server in the path, on chef 11, needs to check for chef-server-ctl
- [COOK-2410] - chef-client::service doesn't always start the chef-client daemon
- [COOK-2413] - Deprecation warning when using Chef::Mixin::Language in chef-client cookbook under chef 11.x
- [COOK-2446] - Typo: the chef-client executable has a hyphen
- [COOK-2492] - Ruby System("") call that includes an '&' on Ubuntu has odd behavior.
- [COOK-2536] - On Freebsd - chef-client group values in helper library should be set to "wheel" vs [ "wheel" ]

v2.2.0
------
- [COOK-2317] - Provide the ability to add disabled ohai plugins in a managed chef config
- [COOK-2255] - Chef-Client Cookbook init.d script under ubuntu

v2.1.10
------
- [COOK-2316] - Permissions for SMF init type break Solaris 10

v2.1.8
------
- [COOK-2192] - Add option to use cron_d resource for cron management
- [COOK-2261] - pin runit dependency

v2.1.6
------
- [COOK-1978] - make cron output location configurable
- [COOK-2169] - use helper library to make path permissions consistent
- [COOK-2170] - test filename cleanup (dev repository only)

v2.1.4
------
- [COOK-2108] - corrected Chef and Ohai version requirements in README

v2.1.2
------
- [COOK-2071] - chef-client breaks on value_for_platform_family b/c of unneeded version
- [COOK-2072] - chef-client on mac should not attempt to create directory nil
- [COOK-2086] - Allow the passing of an enviornment variables to node['chef-client']['bin']
- [COOK-2092] - chef-client run fails because quotes in log_path cause File resource to fail

v2.1.0
------
- [COOK-1755] - Don't delete the validation key on systems that have a 'chef-server' binary in the default $PATH
- [COOK-1898] - Support Handlers and Cache Options with Attributes
- [COOK-1923] - support chef-client::cron on Solaris/SmartOS
- [COOK-1924] - use splay for size of random offset in chef-client::cron
- [COOK-1927] - unknown node[:fqdn] prevents bootstrap if chef-client::cron is in runlist
- [COOK-1951] - Add an attribute for additional daemon options to pass to the chef-client service
- [COOK-2004] - in attributes, "init" style claims to handle fedora, but service.rb missing a clause
- [COOK-2017] - Support alternate chef-client locations in Mac OS X Launchd service plist
- [COOK-2052] - Log files are set to insecure default

v2.0.2
------
- Remove a stray comma that caused syntax error on some versions of Ruby.

v2.0.0
------
This version uses platform_family attribute, making the cookbook incompatible with older versions of Chef/Ohai, hence the major version bump.

- [COOK-635] - Allow configuration of path to chef-client binary in init script
- [COOK-985] - set correct permissions on run and log directory for chef-servers using this cookbook
- [COOK-1379] - Register chef-client as a launchd service on Mac OS X (Server)
- [COOK-1574] - config recipe doesn't work on Windows
- [COOK-1586] - add SmartOS support
- [COOK-1633] - chef-client doesn't recognise Oracle Linux, a Redhat family member
- [COOK-1634] - chef-client init is missing for Scientific Linux
- [COOK-1664] - corrected permissions in cron recipe (related to COOK-985)
- [COOK-1729] - support windows task
- [COOK-1788] - `init_style` upstart only works on Ubuntu
- [COOK-1861] - Minor styling fix for consistency in chef-client
- [COOK-1862] - add `name` attribute to metadata.rb

v1.2.0
------
This version of the cookbook also adds minitest and test-kitchen support.

- [COOK-599] - chef-client::config recipe breaks folder permissions of chef-server::rubygems-install recipe on same node
- [COOK-1111] - doesn't work out of the box with knife bootstrap windows
- [COOK-1161] - allow setting log file and environment in client.rb
- [COOK-1203] - allow PATH setting for cron
- [COOK-1254] - service silently fails on ubuntu 12.04 with ruby 1.9.3
- [COOK-1309] - cron recipe expects SANE_PATHS constant
- [COOK-1345] - preformat log location before sending to template
- [COOK-1377] - allow client.rb to require gems
- [COOK-1419] - add init script for SUSE
- [COOK-1463] - Add verbose_logging knob for config recipe, client.rb template
- [COOK-1506] - set an attribute for server_url
- [COOK-1566] - remove random splay for unique sleep number

v1.1.4
------
- [COOK-599] - don't break folder permissions if chef-server recipe is present

v1.1.2
------
- [COOK-1039] - support mac_os_x_server

v1.1.0
------
- [COOK-909] - trigger upstart on correct event
- [COOK-795] - add windows support with winsw
- [COOK-798] - added recipe to run chef-client as a cron job
- [COOK-986] - don't delete the validation.pem if chef-server recipe is detected

v1.0.4
------
- [COOK-670] - Added Solaris service-installation support for chef-client cookbook.
- [COOK-781] - chef-client service recipe fails with chef 0.9.x

v1.0.2
------
- [CHEF-2491] init scripts should implement reload

v1.0.0
------
- [COOK-204] chef::client pid template doesn't match package expectations
- [COOK-491] service config/defaults should not be pulled from Chef gem
- [COOK-525] Tell bluepill to daemonize chef-client command
- [COOK-554] Typo in backup_path
- [COOK-609] chef-client cookbook fails if init_type is set to upstart and chef is installed from deb
- [COOK-635] Allow configuration of path to chef-client binary in init script
