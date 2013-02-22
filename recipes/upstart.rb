#
# Author:: Jennifer Frisk
# Cookbook Name:: chef-client
# Recipe:: upstart
#
# Copyright 2012-2013, Opscode, Inc.
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
  
  if (8.04..9.04).include?(node["platform_version"].to_f)
    upstart_job_dir = "/etc/event.d"
    upstart_job_suffix = ""
  else
    upstart_job_dir = "/etc/init"
    upstart_job_suffix = ".conf"
  end

  template "#{upstart_job_dir}/chef-client-upstart#{upstart_job_suffix}" do
    source "debian/init/chef-client-upstart.conf.erb"
    mode 0644
    variables(
      :client_bin => client_bin
    )
    notifies :restart, "service[chef-client-upstart]", :delayed
  end

  service "chef-client-upstart" do
    provider Chef::Provider::Service::Upstart
    action [:enable,:start]
  end