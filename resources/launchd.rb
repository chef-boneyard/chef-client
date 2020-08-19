#
# Cookbook:: chef-client
# Resource:: chef_client_launchd
#
# Copyright:: Chef Software, Inc.
#

resource_name :chef_client_launchd
provides :chef_client_launchd

property :interval, Integer, default: 30, description: 'Time in minutes between Chef Infra Client executions'

action :enable do
  template '/Library/LaunchDaemons/com.chef.chef-client.plist' do
    cookbook 'desktop-config'
    source 'com.chef.chef-client.plist.erb'
    owner 'root'
    group 'wheel'
    mode '0644'
    variables(
      interval: new_resource.interval * 60
    )
  end

  launchd 'com.chef.chef-client' do
    path '/Library/LaunchDaemons/com.chef.chef-client.plist'
    action [:create, :enable]
  end
end

action :disable do
  service 'chef-client' do
    service_name 'com.chef.chef-client'
    action :disable
  end
end
