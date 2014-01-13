# include helper methods
class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

# libraries/helpers.rb method to DRY directory creation resources
client_bin = find_chef_client
node.default['chef_client']['bin'] = client_bin
create_directories

include_recipe 'runit'
runit_service 'chef-client'
