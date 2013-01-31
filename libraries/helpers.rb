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

      def dir_owner
        chef_server? ? "chef" : "root"
      end

      def root_group
        ["openbsd", "freebsd", "mac_os_x"].include?(node['platform']) ? "wheel" : "root"
      end

      def dir_group
        if chef_server?
          "chef"
        else
          root_group
        end
      end

      def create_directories
        o = dir_owner
        g = dir_group
        %w{run_path cache_path backup_path log_dir conf_dir}.each do |key|
          directory node["chef_client"][key] do
            recursive true
            mode 00750 if key == "log_dir"
            owner o
            group g
            not_if node["platform"]  == "windows"
          end
        end
      end

      def find_chef_client
        if node["platform"] == "windows"
          existence_check = :exists?
          # Where will also return files that have extensions matching PATHEXT (e.g.
          # *.bat). We don't want the batch file wrapper, but the actual script.
          which = 'set PATHEXT=.exe & where'
          Chef::Log.debug "Using exists? and 'where', since we're on Windows"
        else
          existence_check = :executable?
          which = 'which'
          Chef::Log.debug "Using executable? and 'which' since we're on Linux"
        end
      
        chef_in_sane_path = lambda do
          begin
            Chef::Client::SANE_PATHS.map do |p|
              p="#{p}/chef-client"
              p if ::File.send(existence_check, p)
            end.compact.first
          rescue NameError
            false
          end
        end

        # COOK-635 account for alternate gem paths
        # try to use the bin provided by the node attribute
        if ::File.send(existence_check, node["chef_client"]["bin"])
          Chef::Log.debug "Using chef-client bin from node attributes"
          node["chef_client"]["bin"]
        # search for the bin in some sane paths
        elsif Chef::Client.const_defined?('SANE_PATHS') && chef_in_sane_path.call
          Chef::Log.debug "Using chef-client bin from sane path"
          chef_in_sane_path
        # last ditch search for a bin in PATH
        elsif (chef_in_path=%x{#{which} chef-client}.chomp) && ::File.send(existence_check, chef_in_path)
          Chef::Log.debug "Using chef-client bin from system path"
          chef_in_path
        else
          raise "Could not locate the chef-client bin in any known path. Please set the proper path by overriding node['chef_client']['bin'] in a role."
        end
      end
    end
  end
end
