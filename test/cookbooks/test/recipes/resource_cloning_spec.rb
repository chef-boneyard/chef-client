# include helper methods
class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

directory node['chef_client']['conf_dir'] do
  recursive false
  owner 'fake'
  group 'fake'
end

create_chef_directories
