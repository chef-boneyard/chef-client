require File.expand_path('../helpers', __FILE__)

describe 'chef-client::service' do
  include Helpers::ChefClient
  it "starts the chef-client service" do
    service("chef-client").must_be_running
  end
end
