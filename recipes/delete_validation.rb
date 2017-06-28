#
# Author:: Joshua Timberman <joshua@chef.io>
# Cookbook::  chef
# Recipe:: delete_validation
#
# Copyright:: 2010-2017, Chef Software, Inc.
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

class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

# Don't do anything run running as solo or zero in Test-Kitchen. This can happen when using ChefSpec or
# Test Kitchen.
if Chef::Config[:solo] || (Chef::Config[:chef_server_url].include?('localhost') && ENV['TEST_KITCHEN'])
  if !ENV['TEST_KITCHEN'] && !defined?(ChefSpec)
    Chef::Log.info('[chef-client::delete_validation] Skipping validation ' \
      'delete because we are running under chef-solo')
  end
  return
end

unless Chef::Config[:validation_key].nil?
  file Chef::Config[:validation_key] do
    action :delete
    backup false
    only_if { ::File.exist?(Chef::Config[:client_key]) }
  end
end
