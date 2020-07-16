#
# Cookbook::  chef-client
# Recipe:: src_service
#
# Author:: Julian C. Dunn (<jdunn@chef.io>)
#
# Copyright:: 2014-2019, Chef Software, Inc.
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

# include helper methods
class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

# libraries/helpers.rb method to DRY directory creation resources
client_bin = find_chef_client
Chef::Log.debug("Using #{node['chef_client']['dist']}-client binary at #{client_bin}")
node.default['chef_client']['bin'] = client_bin
create_chef_directories

execute "install #{node['chef_client']['svc_name']} in SRC" do
  command "mkssys -s #{node['chef_client']['svc_name']} -p #{node['chef_client']['bin']} -u root -S -n 15 -f 9 -o #{node['chef_client']['log_dir']}/#{node['chef_client']['log_file']} -e #{node['chef_client']['log_dir']}/#{node['chef_client']['log_file']} -a '-i #{node['chef_client']['interval']} -s #{node['chef_client']['splay']}'"
  not_if "lssrc -s #{node['chef_client']['svc_name']}"
  action :run
end

execute "enable #{node['chef_client']['svc_name']}" do
  if node['chef_client']['ca_cert_path']
    command "mkitab '#{node['chef_client']['svc_name']}:2:once:/usr/bin/startsrc -e \"SSL_CERT_FILE=#{node['chef_client']['ca_cert_path']}\" -s #{node['chef_client']['svc_name']} > /dev/console 2>&1'"
  else
    command "mkitab '#{node['chef_client']['svc_name']}:2:once:/usr/bin/startsrc -s #{node['chef_client']['svc_name']} > /dev/console 2>&1'"
  end
  not_if "lsitab #{node['chef_client']['svc_name']}"
end

service node['chef_client']['svc_name'] do
  action :start
end
