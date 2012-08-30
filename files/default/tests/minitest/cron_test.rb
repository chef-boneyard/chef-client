require File.expand_path('../helpers', __FILE__)

describe 'chef-client::cron' do
  include Helpers::ChefClient
  it 'creates the cron job for chef-client' do
    cron("chef-client").must_exist
  end
end
