#
# Cookbook:: chef-client
# resource:: chef_client_trusted_certificate
#
# Copyright:: 2020, Chef Software, Inc.
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

chef_version_for_provides '< 16.5' if respond_to?(:chef_version_for_provides)

provides :chef_client_trusted_certificate
resource_name :chef_client_trusted_certificate

unified_mode true if respond_to?(:unified_mode)

property :cert_name, String, name_property: true

# this version check can go away once this is ported into chef itself
property :certificate, String, required: Chef::VERSION.to_i >= 16 ? [:add] : true

action :add do
  unless ::Dir.exist?(Chef::Config[:trusted_certs_dir])
    directory Chef::Config[:trusted_certs_dir] do
      mode '0640'
      recursive true
    end
  end

  file cert_path do
    content new_resource.certificate
    mode '0640'
  end
end

action :remove do
  file cert_path do
    action :delete
  end
end

action_class do
  #
  # The path to the string on disk
  #
  # @return [String]
  #
  def cert_path
    path = ::File.join(Chef::Config[:trusted_certs_dir], new_resource.cert_name)
    path << '.pem' unless path.end_with?('.pem')
    path
  end
end
