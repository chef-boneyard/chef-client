# include helper methods
class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

require 'chef/version_constraint'

# libraries/helpers.rb method to DRY directory creation resources
client_bin = find_chef_client
Chef::Log.debug("Found chef-client in #{client_bin}")
node.default['chef_client']['bin'] = client_bin
create_directories

version_checker = Gem::Requirement.new(">= 0.10.10")
mac_service_supported = version_checker.satisfied_by?(Gem::Version.new(node['chef_packages']['chef']['version']))

if mac_service_supported

  file '/Library/LaunchDaemons/com.opscode.chef-client.plist' do
    action :delete
    notifies :stop, 'service[com.opscode.chef-client]'
  end

  template '/Library/LaunchDaemons/com.chef.chef-client.plist' do
    source 'com.chef.chef-client.plist.erb'
    mode 0644
    variables(
      :launchd_mode => node['chef_client']['launchd_mode'],
      :client_bin => client_bin
    )
  end

  service 'com.opscode.chef-client' do
    action :nothing
  end

  service 'chef-client' do
    service_name 'com.chef.chef-client'
    provider Chef::Provider::Service::Macosx
    action :start
  end
else
  log('Mac OS X Service provider is only supported in Chef >= 0.10.10') { level :warn }
end
