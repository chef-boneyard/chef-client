require File.expand_path('../helpers', __FILE__)

describe 'chef-client::delete_validation' do
  include Helpers::ChefClient
  it 'deletes the validation key file' do
    file(Chef::Config[:validation_key]).wont_exist
  end
end
