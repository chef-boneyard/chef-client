## v2.1.6:

* [COOK-1978] - make cron output location configurable
* [COOK-2169] - use helper library to make path permissions consistent
* [COOK-2170] - test filename cleanup (dev repository only)

## v2.1.4:

* [COOK-2108] - corrected Chef and Ohai version requirements in README

## v2.1.2:

* [COOK-2071] - chef-client breaks on value_for_platform_family b/c of
  unneeded version
* [COOK-2072] - chef-client on mac should not attempt to create
  directory nil
* [COOK-2086] - Allow the passing of an enviornment variables to
  node['chef-client']['bin']
* [COOK-2092] - chef-client run fails because quotes in log_path cause
  File resource to fail

## v2.1.0:

* [COOK-1755] - Don't delete the validation key on systems that have a
  'chef-server' binary in the default $PATH
* [COOK-1898] - Support Handlers and Cache Options with Attributes
* [COOK-1923] - support chef-client::cron on Solaris/SmartOS
* [COOK-1924] - use splay for size of random offset in
  chef-client::cron
* [COOK-1927] - unknown node[:fqdn] prevents bootstrap if
  chef-client::cron is in runlist
* [COOK-1951] - Add an attribute for additional daemon options to pass
  to the chef-client service
* [COOK-2004] - in attributes, "init" style claims to handle fedora,
  but service.rb missing a clause
* [COOK-2017] - Support alternate chef-client locations in Mac OS X
  Launchd service plist
* [COOK-2052] - Log files are set to insecure default

## v2.0.2:

* Remove a stray comma that caused syntax error on some versions of Ruby.

## v2.0.0:

This version uses platform_family attribute, making the cookbook incompatible
with older versions of Chef/Ohai, hence the major version bump.

* [COOK-635] - Allow configuration of path to chef-client binary in init script
* [COOK-985] - set correct permissions on run and log directory for chef-servers using this cookbook
* [COOK-1379] - Register chef-client as a launchd service on Mac OS X (Server)
* [COOK-1574] - config recipe doesn't work on Windows
* [COOK-1586] - add SmartOS support
* [COOK-1633] - chef-client doesn't recognise Oracle Linux, a Redhat family member
* [COOK-1634] - chef-client init is missing for Scientific Linux
* [COOK-1664] - corrected permissions in cron recipe (related to COOK-985)
* [COOK-1729] - support windows task
* [COOK-1788] - `init_style` upstart only works on Ubuntu
* [COOK-1861] - Minor styling fix for consistency in chef-client
* [COOK-1862] - add `name` attribute to metadata.rb

## v1.2.0:

This version of the cookbook also adds minitest and test-kitchen
support.

* [COOK-599] - chef-client::config recipe breaks folder permissions of
  chef-server::rubygems-install recipe on same node
* [COOK-1111] - doesn't work out of the box with knife bootstrap
  windows
* [COOK-1161] - allow setting log file and environment in client.rb
* [COOK-1203] - allow PATH setting for cron
* [COOK-1254] - service silently fails on ubuntu 12.04 with ruby 1.9.3
* [COOK-1309] - cron recipe expects SANE_PATHS constant
* [COOK-1345] - preformat log location before sending to template
* [COOK-1377] - allow client.rb to require gems
* [COOK-1419] - add init script for SUSE
* [COOK-1463] - Add verbose_logging knob for config recipe, client.rb
  template
* [COOK-1506] - set an attribute for server_url
* [COOK-1566] - remove random splay for unique sleep number

## v1.1.4:

* [COOK-599] - don't break folder permissions if chef-server recipe is present

## v1.1.2:

* [COOK-1039] - support mac_os_x_server

## v1.1.0:

* [COOK-909] - trigger upstart on correct event
* [COOK-795] - add windows support with winsw
* [COOK-798] - added recipe to run chef-client as a cron job
* [COOK-986] - don't delete the validation.pem if chef-server recipe
  is detected

## v1.0.4:

* [COOK-670] - Added Solaris service-installation support for chef-client cookbook.
* [COOK-781] - chef-client service recipe fails with chef 0.9.x

## v1.0.2:

* [CHEF-2491] init scripts should implement reload

## v1.0.0:

* [COOK-204] chef::client pid template doesn't match package expectations
* [COOK-491] service config/defaults should not be pulled from Chef gem
* [COOK-525] Tell bluepill to daemonize chef-client command
* [COOK-554] Typo in backup_path
* [COOK-609] chef-client cookbook fails if init_type is set to upstart and chef is installed from deb
* [COOK-635] Allow configuration of path to chef-client binary in init script
