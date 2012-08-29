#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: chef
# Recipe:: bootstrap_client
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

root_group = value_for_platform(
  ["openbsd", "freebsd", "mac_os_x", "mac_os_x_server"] => { "default" => "wheel" },
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

node["chef_client"]["bin"] = client_bin


%w{run_path cache_path backup_path log_dir}.each do |key|
  directory node["chef_client"][key] do
    recursive true
    # Work-around for CHEF-2633
    unless node["platform"] == "windows"
      owner "root"
      group root_group
    end
    mode 0755
  end
end

case node["chef_client"]["init_style"]
when "init"

  dist_dir, conf_dir = value_for_platform(
    ["ubuntu", "debian"] => { "default" => ["debian", "default"] },
    ["redhat", "centos", "fedora", "scientific", "amazon"] => { "default" => ["redhat", "sysconfig"]},
    ["suse"] => { "default" => ["suse", "sysconfig"] }
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
  local_path = ::File.join(Chef::Config[:file_cache_path], "/")
  template "/lib/svc/method/chef-client" do
    source "solaris/chef-client.erb"
    owner "root"
    group "root"
    mode "0777"
    notifies :restart, "service[chef-client]"
  end
  
  template (local_path + "chef-client.xml") do
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

  case node["platform"]
  when "ubuntu"
    if (8.04..9.04).include?(node["platform_version"].to_f)
      upstart_job_dir = "/etc/event.d"
      upstart_job_suffix = ""
    else
      upstart_job_dir = "/etc/init"
      upstart_job_suffix = ".conf"
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

when "win-service"
  chef_gems_path = Gem.path.map {|g| g if g =~ /chef\/embedded/ }.compact.first.strip
  win_service_manager = File.join(chef_gems_path,"gems","chef-#{Chef::VERSION}","distro","windows","service_manager.rb")

  Chef::Log.debug "Using \"#{win_service_manager}\" to install chef-client Windows Service"

  execute "uninstall chef-client Windows Service" do
    command "#{node["chef_client"]["ruby_bin"]} \"#{win_service_manager}\" --action uninstall"
    notifies :run, "execute[install chef-client Windows Service]", :immediately
    only_if do
        require 'win32/service'
        Win32::Service.exists?('chef-client')
    end
  end

  execute "install chef-client Windows Service" do
    command "#{node["chef_client"]["ruby_bin"]} \"#{win_service_manager}\" --action install -i #{node["chef_client"]["interval"]} -s #{node["chef_client"]["splay"]}"
    notifies :start, "service[chef-client]"
    not_if do
        require 'win32/service'
        Win32::Service.exists?('chef-client')
    end
  end

  service "chef-client" do
    supports :restart => true
    action [ :enable, :start ]
    provider Chef::Provider::Service::Windows
    start_command "#{node["chef_client"]["ruby_bin"]} \"#{win_service_manager}\" --action start"
    stop_command "#{node["chef_client"]["ruby_bin"]} \"#{win_service_manager}\" --action stop"
    restart_command "#{node["chef_client"]["ruby_bin"]} \"#{win_service_manager}\" --action restart"
  end

when "bsd"
  log "You specified service style 'bsd'. You will need to set up your rc.local file."
  log "Hint: chef-client -i #{node["chef_client"]["client_interval"]} -s #{node["chef_client"]["client_splay"]}"
else
  log "Could not determine service init style, manual intervention required to start up the chef-client service."
end
