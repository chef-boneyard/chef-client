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

class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

require 'chef/version_constraint'
require 'chef/exceptions'

# libraries/helpers.rb method to DRY directory creation resources
client_bin = find_chef_client
log "Found chef-client in #{client_bin}"
node.set["chef_client"]["bin"] = client_bin
create_directories

# Services moved to definitions
case node["chef_client"]["init_style"]
when "init"
  init_service "chef-client" do
    bin client_bin
  end
when "smf"
  smf_service "chef-client"
when "upstart"
  upstart_service "chef-client" do
    bin client_bin
  end
when "arch"
  arch_service "chef-client" do
    bin client_bin
  end
when "runit"
  include_recipe "runit"
  runit_service "chef-client"
when "bluepill"
  bluepill_service "chef-client"
when "daemontools"
  daemontools_service "chef-client"
when "winsw"
  winsw_service "chef-client"
when "launchd"
  launchd_service "chef-client" do
    bin client_bin
  end
when "bsd"
  log "You specified service style 'bsd'. You will need to set up your rc.local file."
  log "Hint: chef-client -i #{node["chef_client"]["client_interval"]} -s #{node["chef_client"]["client_splay"]}"
else
  log "Could not determine service init style, manual intervention required to start up the chef-client service."
end
