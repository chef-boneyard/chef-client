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
    # helper methods for use in chef-client recipe code
    module Helpers
      include Chef::DSL::PlatformIntrospection

      def wmi_property_from_query(wmi_property, wmi_query)
        @wmi = ::WIN32OLE.connect('winmgmts://')
        result = @wmi.ExecQuery(wmi_query)
        return nil unless result.each.count > 0
        result.each.next.send(wmi_property)
      end

      def chef_client_service_running
        !wmi_property_from_query(:name, "select * from Win32_Service where name = 'chef-client'").nil?
      end

      def root_owner
        if ['windows'].include?(node['platform'])
          wmi_property_from_query(:name, "select * from Win32_UserAccount where sid like 'S-1-5-21-%-500' and LocalAccount=True")
        else
          'root'
        end
      end

      def create_directories
        # root_owner is not in scope in the block below.
        d_owner = root_owner
        %w(run_path cache_path backup_path log_dir conf_dir).each do |dir|
          # Do not redefine the resource if it exist
          begin
            resources(directory: node['chef_client'][dir])
          rescue Chef::Exceptions::ResourceNotFound
            directory node['chef_client'][dir] do
              recursive true
              mode 00755 if dir == 'log_dir'
              owner d_owner
              group node['root_group']
            end
          end
        end
      end

      def find_chef_client
        if node['platform'] == 'windows'
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
              p = "#{p}/chef-client"
              p if ::File.send(existence_check, p)
            end.compact.first
          rescue NameError
            false
          end
        end

        # COOK-635 account for alternate gem paths
        # try to use the bin provided by the node attribute
        if ::File.send(existence_check, node['chef_client']['bin'])
          Chef::Log.debug 'Using chef-client bin from node attributes'
          node['chef_client']['bin']
        # search for the bin in some sane paths
        elsif Chef::Client.const_defined?('SANE_PATHS') && chef_in_sane_path.call
          Chef::Log.debug 'Using chef-client bin from sane path'
          chef_in_sane_path
        # last ditch search for a bin in PATH
        elsif (chef_in_path = `#{which} chef-client`.chomp) && ::File.send(existence_check, chef_in_path) # ~FC048 Prefer Mixlib::ShellOut is ignored here
          Chef::Log.debug 'Using chef-client bin from system path'
          chef_in_path
        else
          raise "Could not locate the chef-client bin in any known path. Please set the proper path by overriding the node['chef_client']['bin'] attribute."
        end
      end
    end
  end
end
