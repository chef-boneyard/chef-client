#
# Author:: John Dewey (<john@dewey.ws>)
# Cookbook::  chef-client
# Library:: helpers
#
# Copyright:: 2012-2017, John Dewey
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

require 'chef/mixin/shell_out'

module Opscode
  module ChefClient
    # helper methods for use in chef-client recipe code
    module Helpers
      include Chef::DSL::PlatformIntrospection
      include Chef::Mixin::ShellOut

      def wmi_property_from_query(wmi_property, wmi_query)
        @wmi = ::WIN32OLE.connect('winmgmts://')
        result = @wmi.ExecQuery(wmi_query)
        return nil unless result.each.count > 0
        result.each.next.send(wmi_property)
      end

      # Generate a uniformly distributed unique number to sleep.
      def splay_sleep_time(splay)
        if splay.to_i > 0
          seed = node['shard_seed'] || Digest::MD5.hexdigest(node.name).to_s.hex
          seed % splay.to_i
        end
      end

      def root_owner
        if ['windows'].include?(node['platform'])
          wmi_property_from_query(:name, "select * from Win32_UserAccount where sid like 'S-1-5-21-%-500' and LocalAccount=True")
        else
          'root'
        end
      end

      def create_chef_directories
        # root_owner is not in scope in the block below.
        d_owner = root_owner
        %w(run_path file_cache_path file_backup_path log_dir conf_dir).each do |dir|
          # Do not redefine the resource if it exist
          find_resource(:directory, node['chef_client'][dir]) do
            recursive true
            mode '0755' if dir == 'log_dir'
            owner d_owner
            group node['root_group']
          end
        end
      end

      def find_chef_client
        if node['platform'] == 'windows'
          existence_check = :exists?
          # Where will also return files that have extensions matching PATHEXT (e.g.
          # *.bat). We don't want the batch file wrapper, but the actual script.
          which = 'set PATHEXT=.exe & where'
          Chef::Log.debug "Using exists? and 'where' to find the chef-client binary since we're on Windows"
        else
          existence_check = :executable?
          which = 'which'
          Chef::Log.debug "Using executable? and 'which' to find the chef-client binary since we're on *nix"
        end

        # try to use the bin provided by the node attribute
        if ::File.send(existence_check, node['chef_client']['bin'])
          Chef::Log.debug 'Using chef-client bin from node attributes'
          node['chef_client']['bin']
        # last ditch search for a bin in PATH
        elsif (chef_in_path = shell_out("#{which} chef-client").stdout.chomp) && ::File.send(existence_check, chef_in_path)
          Chef::Log.debug 'Using chef-client bin from system path'
          chef_in_path
        else
          raise "Could not locate the chef-client bin in any known path. Please set the proper path by overriding the node['chef_client']['bin'] attribute."
        end
      end

      # Return true/false if node['chef_client']['cron']['environment_variables']
      # is defined.
      def env_vars?
        !!node['chef_client']['cron']['environment_variables']
      end

      # Return node['chef_client']['cron']['environment_variables']
      def env_vars
        node['chef_client']['cron']['environment_variables']
      end

      # Return true/false if node['chef_client']['cron']['priority'] is defined.
      def prioritized?
        !!node['chef_client']['cron']['priority']
      end

      # Determine the process priority for chef-client.
      # Guard against unwanted values, returning nil.
      # Returns the desired priority to use with /bin/nice.
      def process_priority
        return nil unless prioritized?
        if node['platform'] == 'windows'
          Chef::Log.warn 'Cannot prioritize the chef-client process on Windows hosts.'
          return nil
        end

        priority = node['chef_client']['cron']['priority']
        # Convert strings to integers. If we see anything that doesn't match an
        # integer, bail.
        if priority.is_a?(String)
          unless /^-?\d+$/ =~ priority
            Chef::Log.warn "Process priority (#{priority}) is invalid. It must be an integer in the range -20 to 19, inclusize."
            return nil
          end
          priority = priority.to_i
        end

        if priority < -20 || priority > 19
          Chef::Log.warn "Process priority (#{priority}) is invalid. It must be an integer in the range -20 to 19, inclusize."
          return nil
        end
        priority
      end
    end
  end
end

Chef::DSL::Recipe.send(:include, Opscode::ChefClient::Helpers)
Chef::Resource.send(:include, Opscode::ChefClient::Helpers)
