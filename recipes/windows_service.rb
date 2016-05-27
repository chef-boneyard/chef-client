#
# Cookbook Name:: chef-client
# Recipe:: windows_service
#
# Author:: Julian Dunn (<jdunn@chef.io>)
#
# Copyright 2013-2016, Chef Software, Inc.
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
class ::Chef::Resource
  include ::Opscode::ChefClient::Helpers
end

# libraries/helpers.rb method to DRY directory creation resources
create_directories

d_owner = root_owner
install_command = "chef-service-manager -a install -c #{File.join(node['chef_client']['conf_dir'], 'client.service.rb')}"
if Chef::VERSION <= '12.5.1'
  install_command << " -L #{File.join(node['chef_client']['log_dir'], 'client.log')}"
end

template "#{node['chef_client']['conf_dir']}/client.service.rb" do
  source 'client.service.rb.erb'
  owner d_owner
  group node['root_group']
  mode 00644
end

execute 'register-chef-service' do
  command install_command
  not_if { chef_client_service_running }
end

service 'chef-client' do
  action [:enable, :start]
end
