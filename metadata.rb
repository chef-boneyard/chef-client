name              "chef-client"
maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Manages aspects of only chef-client"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "2.2.5"
recipe            "chef-client", "Includes the service recipe by default."
recipe            "chef-client::config", "Configures the client.rb from a template."
recipe            "chef-client::service", "Sets up a client daemon to run periodically"
recipe            "chef-client::delete_validation", "Deletes validation.pem after client registers"
recipe            "chef-client::cron", "Runs chef-client as a cron job rather than as a service"

%w{ ubuntu debian redhat centos fedora oracle suse freebsd openbsd mac_os_x mac_os_x_server windows }.each do |os|
  supports os
end

suggests "bluepill"
suggests "daemontools"
suggests "runit", "<= 0.16.2"
suggests "cron", "<= 1.2.0"
