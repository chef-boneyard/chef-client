#
# Cookbook:: chef-client
# Library:: matchers
#
# Copyright:: 2017, Chef Software, Inc.
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

if defined?(ChefSpec)
  ############################
  # chef_client_scheduled_task
  ############################
  ChefSpec.define_matcher :chef_client_scheduled_task

  def add_chef_client_scheduled_task(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_client_scheduled_task, :add, resource_name)
  end

  def remove_chef_client_scheduled_task(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_client_scheduled_task, :remove, resource_name)
  end

end
