require 'spec_helper'

describe 'test::resource_cloning_spec' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'centos', version: '6.9').converge(described_recipe)
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
