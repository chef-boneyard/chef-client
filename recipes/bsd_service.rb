# Used by chef-client.erb template to find command interpreter
require 'rbconfig'

# include helper meth
class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

# libraries/helpers.rb method to DRY directory creation resources
client_bin = find_chef_client
Chef::Log.debug("Found chef-client in #{client_bin}")
node.default['chef_client']['bin'] = client_bin
create_chef_directories

case node['platform_family']
when 'freebsd'

  directory '/etc/rc.conf.d' do
    owner 'root'
    group 'wheel'
    mode '0644'
    action :create
  end

  template '/usr/local/etc/rc.d/chef-client' do
    owner 'root'
    group 'wheel'
    variables client_bin: client_bin
    mode '755'
  end

  # Remove wrong rc.d script created by an older version of cookbook
  file '/etc/rc.d/chef-client' do
    action :delete
  end

  template '/etc/rc.conf.d/chef' do
    mode '644'
    notifies :start, 'service[chef-client]', :delayed
  end

  service 'chef-client' do
    supports status: true, restart: true
    action [:start]
  end

else
  log "You specified service style 'bsd'. You will need to set up your rc.local file."
  log "Hint: chef-client -i #{node['chef_client']['client_interval']} -s #{node['chef_client']['client_splay']}"
end
