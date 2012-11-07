#
# Author:: Paul Mooring (<paul@opscode.com>)
# Cookbook Name:: chef
# Recipe:: task
#
# Copyright 2011, Opscode, Inc.
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

unless node["platform"] == "windows"
  return "#{node['platform']} is not supported by the #{cookbook_name}::#{recipe_name} recipe"
end

# COOK-635 account for alternate gem paths
# try to use the bin provided by the node attribute
if ::File.exists?(node["chef_client"]["bin"])
  client_bin = node["chef_client"]["bin"]
  Chef::Log.debug "Using chef-client bin from node attributes: #{client_bin}"
# search for the bin in some sane paths
elsif Chef::Client.const_defined?('SANE_PATHS')
  chef_in_sane_path = Chef::Client::SANE_PATHS.map do |p|
    p="#{p}/chef-client"
    p if ::File.exists?(p)
  end.compact.first

  unless chef_in_sane_path.nil?
    client_bin = chef_in_sane_path
    Chef::Log.debug "Using chef-client bin from sane path: #{client_bin}"
  end
# last ditch search for a bin in PATH
elsif (chef_in_path=%x{set PATHEXT=.exe & where chef-client}.chomp) && ::File.exists?(chef_in_path)
  client_bin = chef_in_path
  Chef::Log.debug "Using chef-client bin from system path: #{client_bin}"
else
  raise "Could not locate the chef-client bin in any known path. Please set the proper path by overriding node['chef_client']['bin'] in a role."
end

node.set["chef_client"]["bin"] = client_bin

['run_path', 'cache_path', 'backup_path', 'log_dir'].each do |key|
  directory node["chef_client"][key] do
    recursive true
    mode 0755
  end
end

windows_task "chef-client" do
  run_level :highest
  command "#{node['chef_client']['ruby_bin']} #{node['chef_client']['bin']} \
  -L #{File.join(node['chef_client']['log_dir'], 'client.log')} \
  -c #{File.join(node['chef_client']['conf_dir'], 'client.rb')} -s #{node['chef_client']['splay']}"
  frequency :minute
  frequency_modifier(node['chef_client']['interval'].to_i / 60)
end

