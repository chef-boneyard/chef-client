#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Author:: Bryan Berry (<bryan.berry@gmail.com>)
# Cookbook Name:: chef-client
# Recipe:: cron
#
# Copyright 2009-2011, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "digest/md5"

class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

# COOK-635 account for alternate gem paths
# try to use the bin provided by the node attribute
if ::File.executable?(node["chef_client"]["bin"])
  client_bin = node["chef_client"]["bin"]
  # search for the bin in some sane paths
elsif Chef::Client.const_defined?('SANE_PATHS') && (chef_in_sane_path=Chef::Client::SANE_PATHS.map{|p| p="#{p}/chef-client";p if ::File.executable?(p)}.compact.first) && chef_in_sane_path
  client_bin = chef_in_sane_path
  # last ditch search for a bin in PATH
elsif (chef_in_path=%x{which chef-client}.chomp) && ::File.executable?(chef_in_path)
  client_bin = chef_in_path
else
  raise "Could not locate the chef-client bin in any known path. Please set the proper path by overriding node['chef_client']['bin'] in a role."
end

# libraries/helpers.rb method to DRY directory creation resources
create_directories

dist_dir, conf_dir = value_for_platform_family(
                                        ["debian"] => ["debian", "default"],
                                        ["rhel"] => ["redhat", "sysconfig"]
                                        )

# let's create the service file so the :disable action doesn't fail
case node['platform_family']
when "arch","debian","rhel","fedora","suse","openbsd","freebsd"
  template "/etc/init.d/chef-client" do
    source "#{dist_dir}/init.d/chef-client.erb"
    mode 0755
    variables(
              :client_bin => client_bin
              )
  end

  template "/etc/#{conf_dir}/chef-client" do
    source "#{dist_dir}/#{conf_dir}/chef-client.erb"
    mode 0644
  end

  service "chef-client" do
    supports :status => true, :restart => true
    action [:disable, :stop]
  end

when "openindiana","opensolaris","nexentacore","solaris2","smartos"
  service "chef-client" do
    supports :status => true, :restart => true
    action [:disable, :stop]
    provider Chef::Provider::Service::Solaris
    ignore_failure true
  end
end


# Generate a uniformly distributed unique number to sleep.
checksum   = Digest::MD5.hexdigest "#{node['fqdn'] or 'unknown-hostname'}"
sleep_time = checksum.to_s.hex % node['chef_client']['splay'].to_i
env        = node['chef_client']['cron']['environment_variables']
log_file   = node["chef_client"]["cron"]["log_file"]

# If "use_cron_d" is set to true, delete the cron entry that uses the cron
# resource built in to Chef and instead use the cron_d LWRP.
if node['chef_client']['cron']['use_cron_d']
  cron "chef-client" do
    action :delete
  end

  cron_d "chef-client" do
    minute  node['chef_client']['cron']['minute']
    hour    node['chef_client']['cron']['hour']
    path    node['chef_client']['cron']['path'] if node['chef_client']['cron']['path']
    user    "root"
    shell   "/bin/bash"
    command "/bin/sleep #{sleep_time}; #{env} #{client_bin} &> #{log_file}"
  end
else
  cron_d "chef-client" do
    action :delete
  end

  cron "chef-client" do
    minute  node['chef_client']['cron']['minute']
    hour    node['chef_client']['cron']['hour']
    path    node['chef_client']['cron']['path'] if node['chef_client']['cron']['path']
    user    "root"
    shell   "/bin/bash"
    command "/bin/sleep #{sleep_time}; #{env} #{client_bin} &> #{log_file}"
  end
end
