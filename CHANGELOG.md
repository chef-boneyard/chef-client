# chef-client Cookbook CHANGELOG

This file is used to list changes made in each version of the chef-client cookbook.

## 12.3.4 (2021-04-24)

- Fixed logging to /dev/null. - [@gholtiii](https://github.com/gholtiii)

## 12.3.3 (2020-10-30)

- Fixed stop init.d service stopping other process issue. - [@antima-gupta](https://github.com/antima-gupta)

## 12.3.2 (2020-10-04)

- Standardise files with files in chef-cookbooks/repo-management - [@xorimabot](https://github.com/xorimabot)
- Cookstyle Bot Auto Corrections with Cookstyle 6.18.8 - [@cookstyle](https://github.com/cookstyle)
- Simplify and correct chef-client path determination in cron recipe - [@tas50](https://github.com/tas50)

## 12.3.1 (2020-09-01)

- Fix an accidental rename of client.rb - [@tas50](https://github.com/tas50)

## 12.3.0 (2020-09-01)

- Eliminate some extra spaces in the client.rb template that led to odd trailing lines for many users
- Simplify the launchd recipe to launchd resource directly for better logging - [@tas50](https://github.com/tas50)
- Pull in the chef_client_launchd from Chef Infra Client 16.5. This includes greatly expanded functionality over the existing recipe including the ability to set a splay time and customize config/logging directories  - [@tas50](https://github.com/tas50)
- chef_client_scheduled_task: Only create the log dir if it doesn't exist. Backport from Chef Infra Client - [@tas50](https://github.com/tas50)
- chef_client_scheduled_task: cooerce splay and fix the frequency_modifier default. Backport from Chef Infra Client - [@tas50](https://github.com/tas50)
- Fix setting env vars using cron_d in the cron recipe (resolves #701) - [@ramereth](https://github.com/ramereth)
- Fix functionality of append_log_file parameter for Chef 15 and below - [@ramereth](https://github.com/ramereth)

## 12.2.0 (2020-08-26)

- chef_client_cron: Add nice property to control nice level of the chef-client process - [@tas50](https://github.com/tas50)
- chef_client_cron: Fix the log dir mode to be 750 not 640 - [@tas50](https://github.com/tas50)
- chef_client_cron: Fix cron vs. crond_d determination in the :remove action - [@tas50](https://github.com/tas50)

## 12.1.0 (2020-08-19)

- Remove the `file_staging_uses_destdir` since this should not be set for most users - [@lamont-granquist](https://github.com/lamont-granquist)
- Add new `chef_client_trusted_certificate` resource for adding certificates for use within the client - [@tas50](https://github.com/tas50)

## 12.0.1 (2020-08-07)

- Ensure that client config reloads in kitchen across multiple runs. - [@jjustice6](https://github.com/jjustice6)
- Fix quoting behavior in Windows Scheduled Task jobs - [@patcable](https://github.com/patcable)
- Fix systemd_timer_resource :remove action failures - [@tas50](https://github.com/tas50)
- Fix the location of the FreeBSD templates - [@tas50](https://github.com/tas50)

## 12.0.0 (2020-08-05)

### Breaking Changes

- Default cron times have been updated to run every 30 minutes instead of every 4 hours
- The default binary path on Linux, macOS and other *nix operating systems has been changed from `/usr/bin/chef-client` to `/opt/chef/bin/chef-client`
- The upstart service recipe has been removed as Ubuntu 14.04 is now EOL
- Support for non-RHEL platforms in the init service recipe has been removed as only RHEL 6 / Amazon 201x should need sys-v init support at this point
- The `node['chef_client']['cache_path']` attribute has been renamed to `node['chef_client']['file_cache_path']` and will properly be set in the client.rb if changed now. However, this attribute is unset by default as it causes issues on first client runs. Enable it at your own risk.
- The `node['chef_client']['backup_path']` attribute has been renamed to `node['chef_client']['file_backup_path']` and will properly be set in the client.rb if changed now.
- The `chef_client_scheduled_task` resource no longer uses the `node['chef_client']['log_file']` to set the log file name and intead had a new `log_file_name` property that defaults to `chef-client.log` matching the attributes default value.
- A new `client.rb` configuration option `file_staging_uses_destdir` is set via `node['chef_client']['file_staging_uses_destdir']`, which defaults to true.
- Enable cron_d support on Linux by default - [@tas50](https://github.com/tas50)
- Append to the chef-client log by default - [@tas50](https://github.com/tas50)

### Other changes

- Add `chef_client_cron` and `chef_client_systemd_timer` resources from Chef Infra Client 16 - [@tas50](https://github.com/tas50)
- Use `random_delay` property in windows_task for splay
- Update the cron recipe to use chef_client_cron resource - [@tas50](https://github.com/tas50)
- Simplify how we disable the existing service in cron recipe - [@tas50](https://github.com/tas50)
- Prevent chef-client launchd from unloading itself and add Catalina workaround (#651) - [@jazaval](https://github.com/jazaval)
- Additional space removed from cron recipe - [@sanga1794](https://github.com/sanga1794)
- Add log_file_name property to chef_client_scheduled_task to match Chef Infra Client 16  - [@tas50](https://github.com/tas50)
- Make sure to create the log directory in chef_client_scheduled_task - [@tas50](https://github.com/tas50)
- Update the task recipe to use the log_file attribute - [@tas50](https://github.com/tas50)
- chef_client_cron: Don't cleanup legacy cron entries. The legacy recipe code we're cleaning up here was replaced many years ago - [@tas50](https://github.com/tas50)
- Add a new property `accept_chef_license` to the resources - [@tas50](https://github.com/tas50)
- Prevent failures when setting certain frequency types - [@tas50](https://github.com/tas50)
- Add `run_on_battery` property to scheduled_task - [@tas50](https://github.com/tas50)
- Remove the legacy service name cleanup for launchd - [@tas50](https://github.com/tas50)
- Ensure we have resource_name in addition to provides in resources - [@tas50](https://github.com/tas50)
- Use windows? helper where we can - [@tas50](https://github.com/tas50)
- Switch testing from Travis to GitHub Actions
- Various Cookstyle fixes

### Other Changes

- The splay time generation for cron jobs has been corrected
- The `chef_client_scheduled_task` resource will no longer fail if the `frequency` property is set to a value other than `once`, `minute`, `hourly`, `daily`, `weekly`, or `monthly`
- The `chef_client_scheduled_task` resource now creates the log directory specified in the resource.
- A new `chef_client_cron` has been added for setting up Chef Infra Client to run as a cron job.

## 11.5.0 (2020-01-22)

- Simplify platform checks by using platform? helper - [@tas50](https://github.com/tas50)
- Notify :immediately not :immediate - [@tas50](https://github.com/tas50)
- Update the chefignore to include more files - [@tas50](https://github.com/tas50)
- Remove SLES 11 specs since it's EOL - [@tas50](https://github.com/tas50)
- Specify OPTIONS in /etc/defaults for Debian systemd platforms - [@e1ven](https://github.com/e1ven)

## 11.4.0 (2019-11-13)

- Add support for ohai.optional_plugins with a new attribute - [@cnaude](https://github.com/cnaude)

## 11.3.6 (2019-10-24)

This release removes `default['chef_client']['config']['client_fork'] = true` from the attributes file.

Having this default value in place adds --fork to the chef-client run,  which forces --fork on cli use of chef-client as well. This causes additional issues for CLI use where the supervisor chef-client process is not necessary or required. The use of the --interval flag or --once or similar flags correctly gets the default setting of fork/no-fork right and that behavior inside the chef-client should be left alone.

A concrete example of the kind of problems this causes is that running the chef_client_updater cookbook from the command line will send SIGKILL to the PPID if it is running with client_fork. that is the correct behavior, but for some reason that can SIGKILL the shell running chef-client as well, which is some kind of weird process-group leader issue -- one which i don't have the time to research so the best solution is that CLI invocation of the client should never fork (because the supervisor process on a CLI invocation is super duper 100.% useless) but with client_fork true that means everyone needs to know to use --no-fork on every command line invocation -- but forking works fine for 99% of the time until you hit the use cases where it doesn't.

## 11.3.5 (2019-10-18)

- convert symbol-like log_location to symbols - [@dwmarshall](https://github.com/dwmarshall)
- make sure node[chef_client][cron][nice_path] is used everywhere - [@scalp42](https://github.com/scalp42)
- Update the platforms we test on in Test Kitchen - [@tas50](https://github.com/tas50)
- Remove the EOL platform opensuse from the metadata - [@tas50](https://github.com/tas50)

## 11.3.4 (2019-10-01)

- Add ignore_failure to the windows_service stop - [@tas50](https://github.com/tas50)

## 11.3.3 (2019-10-01)

- Stop chef-client windows service after creating scheduled task - [@jasonwbarnett](https://github.com/jasonwbarnett)
- Allow changing nice path - [@scalp42](https://github.com/scalp42)
- Do not restart try to restart the timer when switching to service mode - [@Annih](https://github.com/Annih)
- Restart chef-client service after only when timer is setup - [@Annih](https://github.com/Annih)

## 11.3.2 (2019-10-01)

- Remove long_description and recipe metadata from metadata.rb - [@tas50](https://github.com/tas50)
- Fix chef-client.service reload - [@dheerajd-msys](https://github.com/dheerajd-msys)

## 11.3.1 (2019-09-17)

- MSYS-1092 Fix for nil class error if chef client handlers are not defined. - [@Vasu1105](https://github.com/Vasu1105)
- Removed unwanted condition - [@Vasu1105](https://github.com/Vasu1105)
- Fix for nil class error if chef client handlers are not defined. (#635) - [@lamont-granquist](https://github.com/lamont-granquist)

## 11.3.0 (2019-08-19)
- Added KillMode option for systemd - [@kimbernator](https://github.com/kimbernator)

## 11.2.0 (2019-04-30)

- Added the ability to accept upcoming Chef 15+ license via attribute - [@tyler-ball](https://github.com/tyler-ball)

## 11.1.3 (2019-04-08)

- Replace :reload with :restart - [@americanhanko](https://github.com/americanhanko)
- Update the macos launchd plist to use instance vars - [@americanhanko](https://github.com/americanhanko)
- Unit tests for launchd_service recipe - [@americanhanko](https://github.com/americanhanko)

## 11.1.2 (2019-04-02)

- Restart daemon on macOS if configuration is changed - [@pludi](https://github.com/pludi)
- Skip managing cron.d on any non-Linux platform not just non-AIX platforms - [@jjustice6](https://github.com/jjustice6)

## 11.1.1 (2019-03-18)

- fix systemd timer activation - [@nathwill](https://github.com/nathwill)

## 11.1.0 (2019-03-18)

- Add windows 2016 vagrant testing to the kitchen config - [@tas50](https://github.com/tas50)
- Added `onstart` scheduled task to test recipe and updated `chef_client_scheduled_task` resource - [@gdavison](https://github.com/gdavison)
- Update Kitchen testing to include our new amazonlinux-2 box - [@tas50](https://github.com/tas50)

## 11.0.5 (2019-01-25)

- Changes systemd timer to trigger on OnActiveSec - [@ngharo](https://github.com/ngharo)

## 11.0.4 (2019-01-11)

- Prepend :: to File call - [@jasonwbarnett](https://github.com/jasonwbarnett)
- Fix missing log_dir attribute in task recipe for windows - [@pschaumburg](https://github.com/pschaumburg)
- Fix for specifying known path for cmd.exe on a windows system to avoid nefarious PATH settings
- Fix idempotency in the task resource - [@pschaumburg](https://github.com/pschaumburg)

## 11.0.3 (2018-10-29)

- Fix duplicate daemon options
- Create the Chef log directory if missing. Otherwise scheduled tasks fail.

## 11.0.2 (2018-10-12)

- Do not attempt to delete a cron_d resource on AIX hosts.

## 11.0.1 (2018-09-14)

- [cron] Be notified of chef-client failure if mailto is defined
- Chef 14.4.0 requires double quotes around command for scheduled task

## 11.0.0 (2018-07-24)

- Remove windows cookbook dep and require Chef 13.0 instead for the windows_task resource.

## 10.1.2 (2018-07-23)

- scheduled task user and password should be marked as sensitive
- Renames helper method.

## 10.1.1 (2018-07-13)

- Renames the `env` helper method to `env_vars` to address a Windows bug introduced
  in `10.1.0`.
- Addresses issue #579.

## 10.1.0 (2018-07-03)

- Adds support for prioritizing `chef-client` via `nice`.

## 10.0.5 (2018-05-10)

- fix issues with a new instance where `chef-client` service is not found on Upstart systems (Ubuntu 14.04)

## 10.0.4 (2018-04-24)

- [GH-558] Add chef_client_scheduled_task name property
- Fix FC108: Resource should not define a property named 'name'

## 10.0.3 (2018-04-13)

- Fix the handling of log_locations that aren't strings
- Use RandomizedDelaySec as it is better suited in systemd
- Fix failures on Windows with Chef 14

## 10.0.2 (2018-03-18)

- Fix systemd ignoring ca_cert_path on rhel

## 10.0.1 (2018-03-09)

- Update the debug message for the chef-client binary
- Update the recipe to state we require Chef 12.11 not 12.1
- Add some specs for the SLES 11 init file
- Add more specs for SLES 11 init script
- Fail hard if the specified service type is not valid
- handle mixed lines if log_location is nil in the config
- handle empty (but not nil) handlers block in the config

## 10.0.0 (2018-02-14)

- The behavior of when to include the node name in the client.rb has been changed and the node name will now always be included to avoid various errors if we skip it. This is the correct behavior, but the cookbook has received a major version bump so users can properly test the new behavior.
- Fix a frozen string warning when passing daemon options to a cron job
- Don't include the daemon options if they don't exist.
- Chefspec matchers have been removed since Chefspec now autogenerates these

## 9.0.5 (2018-02-05)

- Swap Debian 7 testing for Amazon Linux 2
- Remove unused windows service helper method
- Prevent using -L option if no location of log file is provided.
- update start_date format attribute

## 9.0.4 (2018-01-23)

- Fixes to allow the windows_task resource to work on chef 13.7 while still working on < 13.7

## 9.0.3 (2018-01-22)

- Do not require start, report, or exception handlers to manage `client.rb`. Only write them out if we actually have them
- remove the rendering of the begin rescue block when no handlers are defined.
- Fix wrong daemon options at systemd config
- Fix the SUSE init template to use the correct run_path node attribute
- in the task resource escape the chef-client path with single quotes since you sometimes end up with double-quote escaped attributes
- Improve log messages in the path helper
- Remove code used to support Chef < 12.8, which already wasn't supported by this cookbook
- Remove test kitchen configs for platforms Chef no longer officially supports
- Make sure task doesn't fail on chef-client >= 13.7

## 9.0.2 (2017-11-14)

- Resolve foodcritic warning in notification of ruby_block
- Fix start_date functionality

## 9.0.1 (2017-11-14)

- Require cron cookbook 4.2 which works on SLES 11
- Use a single log resource to warn in FreeBSD instead of two
- Add respond_to to the chef_version in metadata for older clients
- Add a regex to validate start_time passed into the task resource
- Add ability to specify the start_date in task resource

## 9.0.0 (2017-10-23)

### Breaking changes

We have removed the previously deprecated support for running chef-client as a Windows service and running under the runit init system on Linux. Windows hosts should run chef-client as a scheduled task which resolves many issues with long running chef-client processes as a service. For Linux users we highly recommend using the native init systems within your distribution as they provide a higher level of platform support, reliability, and logging integration. For both of these changes we will not be including an automatic migration solution as doing so can prove to be problematic for many users. We recommend stopping the existing chef client and then manually running chef client to create the new service or scheduled task. That may be accomplished using knife ssh, push-jobs, or other tooling within your environment.

### Other Changes

- Add ability to set daemonized SSL trust store
- Add attributes for setting chkconfig start and stop time values in sys-v scripts
- Setup log rotate on any Linux release not just Amazon, RHEL, Debian and Fedora platform families
- In the cron recipe make sure we cleanup the sys-v script and and stop the service on any Linux platform not just Amazon, RHEL, Debian and Fedora platform families
- Add ability to set daemonized SSL trust store.
- Fix exception when log_level is already a symbol when building the client.rb file
- Initialize handler attributes to empty arrays
- Add Clear Linux support
- Fix loading of the solaris service config
- Provide better error messages if the wrong frequency is provided to the scheduled task resource or recipe
- Use full file modes in all recipes
- Add ability to set frequency modifier on the chef-client Windows task as a string instead of just an integer
- Add Travis CI testing of both Chef 12 and 13
- Add Windows 2016 and SLES 11 testing to local Test Kitchen

## 8.1.8 (2017-08-06)

- Add testing for Amazon Linux and Debian 9 in Travis and switch all testing to the dokken images
- Consolidate duplicate attributes to simplify the attributes file
- Remove leftover template file for Arch Linux
- Don't use deprecated Ruby exists? method
- Move testing to a test recipe that looks more like how a user would write a wrapper cookbook
- Move the resource cloning spec recipe into the test recipe so we don't ship it to clients
- Remove the metadata for the deprecated windows service
- Simplify the platform logic in the init service recipe and expand the specs for this logic
- Use resource_name not provides in the scheduled task resource
- Remove docs for the pre-Chef 12.4 syslog functionality
- Point users to chef_client_updater not omnibus_updater in the docs

## 8.1.7 (2017-07-13)

- Add find_chef_client use to the task recipe so that chef_binary_path is defined.
- Update documentation to reflect the rubygems_url usage.

## 8.1.6 (2017-06-27)

- Use node['chef_client']['log_file'] in all recipes and templates
- Add new attribute for timing out systemd timer to kill off hung chef-client runs

## 8.1.5 (2017-06-27)

- Multiple improvements to systemd unit behavior of chef-client

  - stop the timer if timer is disabled
  - de-dupe env-file path referencing
  - ensure env file exists before service that references it
  - restart timer if timer changed

## 8.1.4 (2017-06-21)

- Fix removing the chef-client schedule task

## 8.1.3 (2017-06-21)

- Lazily eval the frequency so an update to interval attribute is respected when setting up a windows scheduled task

## 8.1.2 (2017-05-30)

- convert timer unit to hash syntax for readability,
- use systemd_unit for chef-client.service

## 8.1.1 (2017-05-10)

- Default the systemd restart behavior to always

## 8.1.0 (2017-05-09)

- Allow controlling systemd restart setting through an attribute
- Do not enable the service if systemd timer is used
- Add an example of setting up logging to the Event Viewer on Windows
- Resolve Chef 13 failures when setting up Scheduled Tasks on Windows

## 8.0.2 (2017-05-02)

- Remove the suggests 'runit' from the metadata
- Require a more modern windows and cron cookbook
- Make sure SLES 11 gets the right init system

## 8.0.1 (2017-04-13)

- Make chef_client_scheduled_task idempotent
- Fix case statements to work on Chef 13 with Amazon Linux
- Switch to a SPDX standard license string to resolve foodcritic warning

## 8.0.0 (2017-04-04)

- Allow to use systemd timer instead of chef-client daemon mode
- Remove compat_resource dependency and require Chef 12.11+
- Switch from which to shell-out and remove Chef 10 compatibility code

## 7.2.1 (2017-03-29)

- Testing updates for Chef 13
- Test with local delivery and not Rake
- Disable chef-client service if it exists in the windows schedule task recipe
- Update cron recipe to use shard_seed when available, and node.name when not.

## 7.2.0 (2017-02-24)

- Add a chef_client_scheduled_task custom resource. This is is used by the 'task' recipe, but can also be used directly in a wrapper cookbook. Why would I want to use this? Well when used in a wrapper cookbook you can directly pass the username/password to the resource, thus avoiding node attributes. This means you can store your credentials in any secure method you want.

## 7.1.0 (2017-01-16)

- Fix some poor wording in the readme due to split lines
- Remove a debug message in the windows task recipe
- Add deprecation warning when using the Runit init system

## 7.0.3 (2016-12-06)

- Fix invalid shell syntax in /etc/init.d script

## 7.0.2 (2016-12-02)

- Document / test setting a custom ohai plugin path
- Make log_perm permissions attribute value a string
- Avoid warnings during ChefSpec runs

## 7.0.1 (2016-12-02)

- Fixed cron attributes documentation
- Fix file modes to be strings
- Added SLES support to the readme
- Use regex instead of position for service status

## 7.0.0 (2016-10-25)

### Breaking Changes

- Remove support for OpenBSD
- Remove support for Arch Linux

### Other Changes

- Document 'weekday' in readme
- Adding exception to 5.11 SMF manifest for SmartOS. SmartOS does not have a config milestone
- Add chef-client init back for SLES 12

## 6.0.0 (2016-09-26)

### Breaking Changes

- Support for Chef 11 has been removed. Chef 12.1 or later is now required
- Running chef-client as a service on Windows has been deprecated. The default.rb recipe will now include the task recipe on Windows hosts. The windows_service recipe will be removed in the next major version of this cookbook.

### Other Changes

- Switch from serverspec to Inspec
- Add BSDs to bsd_init to fix cron service
- Simplified attributes for Chef 12 - Chef 12 lets us simplify attributes since we don't have to check to see if we can fork and we can assume we know the init type via Ohai
- Fix validation recipe to not explode under chef-solo.
- Change path for rc.d chef-client script in FreeBSD
- Remove wrong rc.d script created by an older version of cookbook
- Remove duplication from rc.d script template for FreeBSD
- Fix escaping in the Windows task recipe
- Allow STDOUT as a valid log location

## v5.0.0 (2016-07-29)

- This will be the last version of this cookbook that supports Chef 11\. If you are still using Chef 11 you will need to pin to < 6.0
- Support for Bluepill and Daemontools init systems has been removed
- chef_version metadata has been added
- client.d config files are now only explicitly added on Chef < 12.8 to prevent double loading configs
- Rubocop has been replaced by cookstyle for simpler ruby linting
- A new Rakefile that handles missing gems better has been included
- Support for daemon options when running as a Windows scheduled task has been added

## v4.6.0 (2016-06-01)

- Add systemd support to Suse platforms and make systemd the default there as systemd is the init system on all supported suse platforms
- Added a serverspec test for systemd service setup

## v4.5.4 (2016-05-31)

- Updated the systemd unit file to restart on failure and added exit status 3 as a valid successful exit status
- Added the ability to specify retries, retry_delay, timeout in the chef gem install hash

## v4.5.3 (2016-05-27)

- Fixed idempotency of the windows task recipe

## v4.5.2 (2016-05-20)

- Revert switching to ruby based which as this broke compatibility with older Chef clients
- Resolved deprecation warnings with chef_gem installs

## v4.5.1 (2016-05-19)

- Switch from command line which to pure Ruby which in the helper for finding chef-client
- Removed the last bit of Chef 10 compatibility code
- Updated file modes in resources so we properly set the leading 0s
- Switched Travis CI testing to kitchen-dokken and expanded the platforms / suites that are tested
- Added additional service Chefspecs

## v4.5.0 (2016-04-26)

- Updated the client.rb to use ChefConfig::Config.from_file to load config files on Chef 12.4.0\. This resolves NameError messages when running Ohai on its own.

## v4.4.0 (2016-04-20)

- Update the required version of logrorate to >= 1.9.0 and cron to 1.7.0 so we bring in the last few years of bug fixes and feature enhancements
- Removed support for Ubuntu 8.04 - 9.04
- Removed references to the Chef 10 server from the readme
- Updated all references to the community site in the readme to be Supermarket instead
- Documented the scheduled task recipe in the readme
- Added a Test Kitchen suite for the scheduled task recipe on Windows 2008 R2 and 2012 R2
- Add IBM zlinux to the metadata
- Update testing dependencies to the latest
- Remove a duplicate list of `node['chef_client']['interval']` in the readme
- Remove extra spacing and a comment typo in client.rb

## v4.3.3 (2016-02-15)

- [#349] Fix Ohai syntax for > 8.6.0 to remove deprecation warning
- [#316] Make chef-client log permissions configurable
- [#327/#364] Fix chef windows task quoting
- [#341] Update template to use correct milestone for Solaris 11
- [#338] Allow starting chef-client in FreeBSD jails
- Added amazon as a supported platform in the metadata.rb file
- Updated the minimum required windows cookbook to the latest version to resolve issues with scheduled tasks
- Replaced Digital Ocean testing with Kitchen-Docker running in Travis CI
- Expanded platform testing in Test Kitchen and fixed failing ServerSpecs

## v4.3.2 (2015-11-05)

- [#347] windows_service updates client.service.rb with log_location path. This accompanies a change the chef-client that will now honor that configuration for windows_service logging. See <https://github.com/chef/chef/pull/4135>
- [#326] prevent duplicate proxy config properties in client.rb
- [#345] improved wording around deprecated settings in the readme
- Added a chefignore file to limit files being uploaded to the chef server
- Updated contributing and testing docs
- Adding maintainers.md and maintainers.toml files
- Added a Rakefile for simplified testing
- Updated development and testing dependencies to the latest
- Added cookbook version badge and travis status badge to the readme

## v4.3.1 (2015-07-12)

- [#320] don't crash if handler class isn't available
- [#318] default value for password for windows task should be nil
- [#317] properly quote log_location to avoid regex corner case issue
- [#314] fully replace root_group with node['root_group']
- [#310] revert #267; prohibit clients from dictating their environments
- [#307] fix delete_validation recipe under chef-zero
- [#235] workaround chef/chef#3432

## v4.3.0 (2015-04-14)

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

## v4.2.4 (2015-02-18)

- Ripping out chef_gem compile_time stuff

## v4.2.3 (2015-02-18)

- Fixing chef_gem with Chef::Resource::ChefGem.method_defined?(:compile_time)

## v4.2.2 (2015-02-18)

- Fixing chef_gem for Chef below 12.1.0

## v4.2.1 (2015-02-17)

- Being explicit about usage of the chef_gem's compile_time property.
- Eliminating future deprecation warnings in Chef 12.1.0.

## v4.2.0 (2015-02-08)

- [#252] Fix ordering problem with logrotate command attribute
- [#250] Verify API certificates by default in config
- [#238] Remove proxy ENV variables from config
- [#234] Move windows service log directory to correct location

## v4.1.1 (2015-01-30)

- Repair syntax error introduced in config recipe

## v4.1.0 (2015-01-30)

- [#247] Switch Arch Linux to use systemd
- [#243] Improve logrotation configurability
- [#241] Configure logrotate to use systemd when appropriate
- [#239] Allow setting splay in upstart configuration
- [#233] Unbreak unit and integration test harnesses
- [#231] Allow setting NO_PROXY/no_proxy in client.rb
- [#219] Configure log location via client.rb only

## v4.0.0 (2014-12-10)

- [#221] Retire the winsw service wrapper in Windows
- [#227] Add sourcing /etc/default/locale to upstart script
- [#224] Fix FreeBSD service startup
- [#223] Add FreeBSD test harness
- [#217] Fix and modernize systemd configuration

## v3.9.0 (2014-10-15)

- [#208] Add AIX support

## v3.8.2 (2014-09-30)

- [#206] Fixes amazon linux issues introduced in #190

## v3.8.1 (2014-09-30)

- [#202] Avoid resource cloning
- [#190] Use systemd by default on EL7

## v3.8.0 (2014-09-05)

- [#182] Complete refactor of testing. Now uses chefspec and serverspec
- [#134] Update of README to reflect there not being an init recipe
- [#133] Allow windows_task[chef-client] attributes to be overridden
- [#143] Added rc.d script for FreeBSD
- [#155] Allow option to not reload current run Chef config
- [#162] Update cron.rb to work properly for SUSE
- [#169] Sort config hash
- [#184] Changelog fixes

## v3.7.0 (2014-08-13)

- remove dependency on ruby-wmi which breaks chef 11.14.2

## v3.6.0 (2014-06-07)

- [COOK-3465] Switch Fedora to using systemd

## v3.5.0 (2014-05-07)

- [COOK-4594] - 'Found chef-client in' log resource
- Add Windows support to README

## v3.4.0 (2014-04-09)

- [COOK-4521] - support Ohai 7 syntax for disabling plugins
- [COOK-4505] - kill -9 chef-client when stopping via SMF

## v3.3.8 (2014-03-18)

- [COOK-4430] can't rotate chef-client's logs

## v3.3.6 (2014-03-18)

- [COOK-4432] Use SSL verification by default when talking to HEC

## v3.3.4 (2014-03-12)

- [COOK-4101] - Support ENV['https_proxy']

## v3.3.3 (2014-02-27)

[COOK-4338] - chef-client Upstart job starts too early

## v3.3.2 (2014-02-25)

Fixing merge conflict in launchd_service

## v3.3.0 (2014-02-25)

### Bug

- **[COOK-4286](https://tickets.opscode.com/browse/COOK-4286)** - Cleanup the Kitchen
- **[COOK-4242](https://tickets.opscode.com/browse/COOK-4242)** - Add Fedora 19 support to chef-client::cron
- **[COOK-4151](https://tickets.opscode.com/browse/COOK-4151)** - Runit should set locale
- **[COOK-4127](https://tickets.opscode.com/browse/COOK-4127)** - add mailto support for cron runs
- **[COOK-4038](https://tickets.opscode.com/browse/COOK-4038)** - Don't define CHEF_SERVER_USER constant if already defined

### New Feature

- **[COOK-4169](https://tickets.opscode.com/browse/COOK-4169)** - Add the possibility to specify "options" for the required-gems installation procedure in the chef-client cookbook

### Improvement

- **[COOK-4159](https://tickets.opscode.com/browse/COOK-4159)** - turn down "Found chef-client in #{client_bin}" messages to :debug level
- **[COOK-3896](https://tickets.opscode.com/browse/COOK-3896)** - launchd_service recipe should use Gem::Requirement instead of Chef::VersionConstraint

## v3.2.2 (2014-01-26)

[COOK-4092] Add KeepAlive so that launchd will "daemonize" chef-client

## v3.2.0

### Bug

- **[COOK-3885](https://tickets.opscode.com/browse/COOK-3885)** - launchd_service template missing client_bin
- **[COOK-3874](https://tickets.opscode.com/browse/COOK-3874)** - COOK-3492 patch breaks server_test.rb
- **[COOK-3848](https://tickets.opscode.com/browse/COOK-3848)** - allow disable splay
- Fixing up style to pass most rubocops
- Updating test-kitchen harness

## v3.1.2

### Bug

- **[COOK-4113](https://tickets.opscode.com/browse/COOK-4113)** - chef-client::smf_service breaks permissions on /lib/svc/method

## v3.1.0

### Bug

- **[COOK-3638](https://tickets.opscode.com/browse/COOK-3638)** - Use standard posix shell `/bin/sh` instead of `/bin/bash`
- **[COOK-3637](https://tickets.opscode.com/browse/COOK-3637)** - Fix typo in README
- **[COOK-3501](https://tickets.opscode.com/browse/COOK-3501)** - Notify reload `:immediately` when `client.rb` template is changed
- **[COOK-3492](https://tickets.opscode.com/browse/COOK-3492)** - Test upstart on CentOS

### New Feature

- **[COOK-3500](https://tickets.opscode.com/browse/COOK-3500)** - Rotate logs on supported platforms if 'log_file' is set

### Improvement

- **[COOK-1863](https://tickets.opscode.com/browse/COOK-1863)** - Install chef-client as a Windows Service

## v3.0.6

### Bug

- **[COOK-3373](https://tickets.opscode.com/browse/COOK-3373)** - Provide full syslog custom config example in README
- **[COOK-3301](https://tickets.opscode.com/browse/COOK-3301)** - Fix MiniTest Cron Recipe
- **[COOK-3300](https://tickets.opscode.com/browse/COOK-3300)** - Allow environment variables (not require)
- **[COOK-3276](https://tickets.opscode.com/browse/COOK-3276)** - Use `node.default` instead of `node.set`
- **[COOK-3227](https://tickets.opscode.com/browse/COOK-3227)** - Fix misnamed attribute
- **[COOK-3104](https://tickets.opscode.com/browse/COOK-3104)** - Update `.kitchen.yml` to properly set environment_variables

## v3.0.4

### Bug

- [COOK-3159]: don't skip directory creation on Windows

## v3.0.2

### Bug

- [COOK-3157]: correct root group detection for Windows

## v3.0.0

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

## v2.2.4

### Bug

- [COOK-2687]: chef-client::service doesn't work on SLES 11
- [COOK-2689]: chef-client service recipe on windows fails to start
- [COOK-2700]: chef-client cookbook should have more splay
- [COOK-2952]: chef-client cookbook has foodcritic failures

### Sub-task

- [COOK-2823]: Chef-client SMF manifest should set locale to UTF-8

## v2.2.2

- [COOK-2393] - chef-client::delete_validation checks for chef-server in the path, on chef 11, needs to check for chef-server-ctl
- [COOK-2410] - chef-client::service doesn't always start the chef-client daemon
- [COOK-2413] - Deprecation warning when using Chef::Mixin::Language in chef-client cookbook under chef 11.x
- [COOK-2446] - Typo: the chef-client executable has a hyphen
- [COOK-2492] - Ruby System("") call that includes an '&' on Ubuntu has odd behavior.
- [COOK-2536] - On Freebsd - chef-client group values in helper library should be set to "wheel" vs [ "wheel" ]

## v2.2.0

- [COOK-2317] - Provide the ability to add disabled ohai plugins in a managed chef config
- [COOK-2255] - Chef-Client Cookbook init.d script under ubuntu

## v2.1.10

- [COOK-2316] - Permissions for SMF init type break Solaris 10

## v2.1.8

- [COOK-2192] - Add option to use cron_d resource for cron management
- [COOK-2261] - pin runit dependency

## v2.1.6

- [COOK-1978] - make cron output location configurable
- [COOK-2169] - use helper library to make path permissions consistent
- [COOK-2170] - test filename cleanup (dev repository only)

## v2.1.4

- [COOK-2108] - corrected Chef and Ohai version requirements in README

## v2.1.2

- [COOK-2071] - chef-client breaks on value_for_platform_family b/c of unneeded version
- [COOK-2072] - chef-client on mac should not attempt to create directory nil
- [COOK-2086] - Allow the passing of an enviornment variables to node['chef-client']['bin']
- [COOK-2092] - chef-client run fails because quotes in log_path cause File resource to fail

## v2.1.0

- [COOK-1755] - Don't delete the validation key on systems that have a 'chef-server' binary in the default $PATH
- [COOK-1898] - Support Handlers and Cache Options with Attributes
- [COOK-1923] - support chef-client::cron on Solaris/SmartOS
- [COOK-1924] - use splay for size of random offset in chef-client::cron
- [COOK-1927] - unknown node[:fqdn] prevents bootstrap if chef-client::cron is in runlist
- [COOK-1951] - Add an attribute for additional daemon options to pass to the chef-client service
- [COOK-2004] - in attributes, "init" style claims to handle fedora, but service.rb missing a clause
- [COOK-2017] - Support alternate chef-client locations in Mac OS X Launchd service plist
- [COOK-2052] - Log files are set to insecure default

## v2.0.2

- Remove a stray comma that caused syntax error on some versions of Ruby.

## v2.0.0

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

## v1.2.0

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

## v1.1.4

- [COOK-599] - don't break folder permissions if chef-server recipe is present

## v1.1.2

- [COOK-1039] - support mac_os_x_server

## v1.1.0

- [COOK-909] - trigger upstart on correct event
- [COOK-795] - add windows support with winsw
- [COOK-798] - added recipe to run chef-client as a cron job
- [COOK-986] - don't delete the validation.pem if chef-server recipe is detected

## v1.0.4

- [COOK-670] - Added Solaris service-installation support for chef-client cookbook.
- [COOK-781] - chef-client service recipe fails with chef 0.9.x

## v1.0.2

- [CHEF-2491] init scripts should implement reload

## v1.0.0

- [COOK-204] chef::client pid template doesn't match package expectations
- [COOK-491] service config/defaults should not be pulled from Chef gem
- [COOK-525] Tell bluepill to daemonize chef-client command
- [COOK-554] Typo in backup_path
- [COOK-609] chef-client cookbook fails if init_type is set to upstart and chef is installed from deb
- [COOK-635] Allow configuration of path to chef-client binary in init script
