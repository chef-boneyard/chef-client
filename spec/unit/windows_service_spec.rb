require 'spec_helper'

describe 'chef-client::windows_service' do
  let(:chef_run) { ChefSpec::ServerRunner.new(platform: 'windows', version: '2012R2').converge(described_recipe) }

  before do
    allow_any_instance_of(Chef::Recipe).to receive(:create_directories)
    allow_any_instance_of(Chef::Resource).to receive(:chef_client_service_running)
    allow_any_instance_of(Chef::Recipe).to receive(:root_owner).and_return('owner')
  end

  it 'should add log location to config' do
    expect(chef_run).to render_file('C:/chef/client.service.rb')
      .with_content(%r{log_location \"C:/chef/log/client.log\"})
  end
end
