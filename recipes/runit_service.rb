# include helper methods
class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

# libraries/helpers.rb method to DRY directory creation resources
client_bin = find_chef_client
Chef::Log.debug("Found chef-client in #{client_bin}")
node.default['chef_client']['bin'] = client_bin
create_directories

include_recipe 'runit'  # ~FC007: runit is only required when using the runit_service recipe 
runit_service 'chef-client'
