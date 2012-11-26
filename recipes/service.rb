#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: chef-client
# Recipe:: service
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

require 'chef/version_constraint'
require 'chef/exceptions'

root_group = value_for_platform_family(
  ["openbsd", "freebsd", "mac_os_x"] => { "default" => "wheel" },
  "default" => "root"
)

if node["platform"] == "windows"
    existence_check = :exists?
# Where will also return files that have extensions matching PATHEXT (e.g.
# *.bat). We don't want the batch file wrapper, but the actual script.
    which = 'set PATHEXT=.exe & where'
    Chef::Log.debug "Using exists? and 'where', since we're on Windows"
else
    existence_check = :executable?
    which = 'which'
    Chef::Log.debug "Using executable? and 'which' since we're on Linux"
end

# COOK-635 account for alternate gem paths
# try to use the bin provided by the node attribute
if ::File.send(existence_check, node["chef_client"]["bin"])
  client_bin = node["chef_client"]["bin"]
  Chef::Log.debug "Using chef-client bin from node attributes: #{client_bin}"
# search for the bin in some sane paths
elsif Chef::Client.const_defined?('SANE_PATHS') && (chef_in_sane_path=Chef::Client::SANE_PATHS.map{|p| p="#{p}/chef-client";p if ::File.send(existence_check, p)}.compact.first) && chef_in_sane_path
  client_bin = chef_in_sane_path
  Chef::Log.debug "Using chef-client bin from sane path: #{client_bin}"
# last ditch search for a bin in PATH
elsif (chef_in_path=%x{#{which} chef-client}.chomp) && ::File.send(existence_check, chef_in_path)
  client_bin = chef_in_path
  Chef::Log.debug "Using chef-client bin from system path: #{client_bin}"
else
  raise "Could not locate the chef-client bin in any known path. Please set the proper path by overriding node['chef_client']['bin'] in a role."
end

node.set["chef_client"]["bin"] = client_bin


%w{run_path cache_path backup_path log_dir}.each do |key|
  directory node["chef_client"][key] do
    recursive true
    mode 0755
    unless node["platform"] == "windows"
      if node.recipe?("chef-server")
        owner "chef"
        group "chef"
      else
        owner "root"
        group root_group
      end
    end
  end
end


case node["chef_client"]["init_style"]
when "init"

  #argh?
  dist_dir, conf_dir = value_for_platform_family(
    ["debian"] => ["debian", "default"],
    ["rhel"] => ["redhat", "sysconfig"],
    ["suse"] => ["suse", "sysconfig"]
  )

  template "/etc/init.d/chef-client" do
    source "#{dist_dir}/init.d/chef-client.erb"
    mode 0755
    variables(
      :client_bin => client_bin
    )
    notifies :restart, "service[chef-client]", :delayed
  end

  template "/etc/#{conf_dir}/chef-client" do
    source "#{dist_dir}/#{conf_dir}/chef-client.erb"
    mode 0644
    notifies :restart, "service[chef-client]", :delayed
  end

  service "chef-client" do
    supports :status => true, :restart => true
    action :enable
  end

when "smf"
  directory node['chef_client']['method_dir'] do
    action :create
    owner "root"
    group "bin"
    mode "0644"
    recursive true
  end

  local_path = ::File.join(Chef::Config[:file_cache_path], "/")
  template "#{node['chef_client']['method_dir']}/chef-client" do
    source "solaris/chef-client.erb"
    owner "root"
    group "root"
    mode "0777"
    notifies :restart, "service[chef-client]"
  end

  template(local_path + "chef-client.xml") do
    source "solaris/manifest.xml.erb"
    owner "root"
    group "root"
    mode "0644"
    notifies :run, "execute[load chef-client manifest]", :immediately
  end

  execute "load chef-client manifest" do
    action :nothing
    command "svccfg import #{local_path}chef-client.xml"
    notifies :restart, "service[chef-client]"
  end

  service "chef-client" do
    action [:enable, :start]
    provider Chef::Provider::Service::Solaris
  end

when "upstart"

  upstart_job_dir = "/etc/init"
  upstart_job_suffix = ".conf"

  case node["platform"]
  when "ubuntu"
    if (8.04..9.04).include?(node["platform_version"].to_f)
      upstart_job_dir = "/etc/event.d"
      upstart_job_suffix = ""
    end
  end

  template "#{upstart_job_dir}/chef-client#{upstart_job_suffix}" do
    source "debian/init/chef-client.conf.erb"
    mode 0644
    variables(
      :client_bin => client_bin
    )
    notifies :restart, "service[chef-client]", :delayed
  end

  service "chef-client" do
    provider Chef::Provider::Service::Upstart
    action [:enable,:start]
  end

when "arch"

  template "/etc/rc.d/chef-client" do
    source "rc.d/chef-client.erb"
    mode 0755
    variables(
      :client_bin => client_bin
    )
    notifies :restart, "service[chef-client]", :delayed
  end

  template "/etc/conf.d/chef-client.conf" do
    source "conf.d/chef-client.conf.erb"
    mode 0644
    notifies :restart, "service[chef-client]", :delayed
  end

  service "chef-client" do
    action [:enable, :start]
  end

when "runit"

  include_recipe "runit"
  runit_service "chef-client"

when "bluepill"

  directory node["chef_client"]["run_path"] do
    recursive true
    owner "root"
    group root_group
    mode 0755
  end

  include_recipe "bluepill"

  template "#{node["bluepill"]["conf_dir"]}/chef-client.pill" do
    source "chef-client.pill.erb"
    mode 0644
    notifies :restart, "bluepill_service[chef-client]", :delayed
  end

  bluepill_service "chef-client" do
    action [:enable,:load,:start]
  end

when "daemontools"

  include_recipe "daemontools"

  directory "/etc/sv/chef-client" do
    recursive true
    owner "root"
    group root_group
    mode 0755
  end

  daemontools_service "chef-client" do
    directory "/etc/sv/chef-client"
    template "chef-client"
    action [:enable,:start]
    log true
  end

when "winsw"

  directory node["chef_client"]["winsw_dir"] do
    action :create
  end

  template "#{node["chef_client"]["winsw_dir"]}/chef-client.xml" do
    source "chef-client.xml.erb"
    notifies :run, "execute[restart chef-client using winsw wrapper]", :delayed
  end

  winsw_path = File.join(node["chef_client"]["winsw_dir"], node["chef_client"]["winsw_exe"])
  remote_file winsw_path do
    source node["chef_client"]["winsw_url"]
    not_if { File.exists?(winsw_path) }
  end

  # Work-around for CHEF-2541
  # Should be replaced by a service :restart action
  # in Chef 0.10.6
  execute "restart chef-client using winsw wrapper" do
    command "#{winsw_path} restart"
    not_if { WMI::Win32_Service.find(:first, :conditions => {:name => "chef-client"}).nil? }
    action :nothing
  end

  execute "Install chef-client service using winsw" do
    command "#{winsw_path} install"
    only_if { WMI::Win32_Service.find(:first, :conditions => {:name => "chef-client"}).nil? }
  end

  service "chef-client" do
    action :start
  end

when "launchd"

  version_checker = Chef::VersionConstraint.new(">= 0.10.10")
  mac_service_supported = version_checker.include?(node['chef_packages']['chef']['version'])

  if mac_service_supported
    template "/Library/LaunchDaemons/com.opscode.chef-client.plist" do
      source "com.opscode.chef-client.plist.erb"
      mode 0644
      variables(
        :launchd_mode => node["chef_client"]["launchd_mode"]
      )
    end

    service "chef-client" do
      service_name "com.opscode.chef-client"
      provider Chef::Provider::Service::Macosx
      action :start
    end
  else
    log("Mac OS X Service provider is only supported in Chef >= 0.10.10") { level :warn }
  end

when "bsd"
  log "You specified service style 'bsd'. You will need to set up your rc.local file."
  log "Hint: chef-client -i #{node["chef_client"]["client_interval"]} -s #{node["chef_client"]["client_splay"]}"
else
  log "Could not determine service init style, manual intervention required to start up the chef-client service."
end
