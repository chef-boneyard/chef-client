class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

require 'chef/version_constraint'
require 'chef/exceptions'

# libraries/helpers.rb method to DRY directory creation resources
client_bin = find_chef_client
log "Found chef-client in #{client_bin}"
node.set["chef_client"]["bin"] = client_bin
create_directories

include_recipe "runit"
runit_service "chef-client"