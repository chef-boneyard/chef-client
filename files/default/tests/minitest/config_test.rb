require File.expand_path('../helpers', __FILE__)

describe 'chef-client::config' do
  include Helpers::ChefClient
  it 'creates the client config file' do
    file("#{node['chef_client']['conf_dir']}/client.rb").must_exist
  end
end
