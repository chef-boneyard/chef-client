#
# Author:: John Dewey (<john@dewey.ws>)
# Cookbook Name:: chef-client
# Library:: helpers
#
# Copyright 2012, John Dewey
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

module Opscode
  module ChefClient
    module Helpers
      include Chef::Mixin::Language

      def chef_server?
        node.recipe?("chef-server") || system("which chef-server")
      end

      def create_directories
        return if node["platform"] == "windows"
        server = chef_server?

        %w{run_path cache_path backup_path log_dir conf_dir}.each do |key|
          directory node["chef_client"][key] do
            recursive true
            if key == "log_dir"
              mode 00750
            else
              mode 00755
            end
            if server
              owner "chef"
              group "chef"
            else
              owner value_for_platform(
                ["windows"] => { "default" => "Administrator" },
                "default" => "root"
              )
              group value_for_platform_family(
                ["openbsd", "freebsd", "mac_os_x"] => [ "wheel" ],
                "default" => "root"
              )
            end
          end
        end
      end
    end
  end
end
