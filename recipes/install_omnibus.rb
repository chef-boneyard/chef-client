#
# Cookbook Name:: chef-client
# Recipe:: install_omnibus
#
# Copyright 2010, Opscode, Inc.
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

# Acquire the chef-client Omnibus package
if node['chef-client']['package_file'].nil? || node['chef-client']['package_file'].empty?
  omnibus_package = OmnitruckClientClient.new(node).package_for_version(node['chef-client']['version'],
                                                        node['chef-client']['prereleases'],
                                                        node['chef-client']['nightlies'])
  unless omnibus_package
    err_msg = "Could not locate chef-client"
    err_msg << " pre-release" if node['chef-client']['prereleases']
    err_msg << " nightly" if node['chef-client']['nightlies']
    err_msg << " package matching version '#{node['chef-client']['version']}' for node."
    raise err_msg
  end
else
  omnibus_package = node['chef-client']['package_file']
end

package_name = ::File.basename(omnibus_package)
package_local_path = "#{Chef::Config[:file_cache_path]}/#{package_name}"

# omnibus_package is remote (ie a URI) let's download it
if ::URI.parse(omnibus_package).absolute?
  remote_file package_local_path do
    source omnibus_package
    if node['chef-client']['package_checksum']
      checksum node['chef-client']['package_checksum'] if node['chef-client']['package_checksum']
      action :create
    else
      action :create_if_missing
    end
  end
# else we assume it's on the local machine
else
  package_local_path = omnibus_package
end

# install the platform package
package package_name do
  source package_local_path
  provider case node["platform_family"]
           when "debian"; Chef::Provider::Package::Dpkg
           when "rhel"; Chef::Provider::Package::Rpm
           else
            raise RuntimeError("I don't know how to install chef-client packages for platform family '#{node["platform_family"]}'!")
           end
  action :install
end
