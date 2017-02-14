require 'spec_helper'

describe 'chef-client::_unit_test_cloning_resource' do
  let(:chef_run) do
    ChefSpec::ServerRunner.new(platform: 'centos', version: '5.11').converge(described_recipe)
  end

  it 'Create Directory with fake values, without cloning it' do
    expect(chef_run).to create_directory('/etc/chef').with_owner('fake')
    expect(chef_run).to create_directory('/etc/chef').with_group('fake')
  end

  it 'Create Directory with real value, when not exist' do
    expect(chef_run).to create_directory('/var/log/chef').with_owner('root')
    expect(chef_run).to create_directory('/var/log/chef').with_group('root')
  end
end
