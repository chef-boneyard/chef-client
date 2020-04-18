require 'spec_helper'

describe 'chef-client::launchd_service' do
  context 'when self-update attribute is true' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'mac_os_x') do |node|
        node.normal['chef_client']['launchd_self-update'] = true
      end.converge(described_recipe)
    end

    it 'creates the launch daemon' do
      expect(chef_run).to create_template('/Library/LaunchDaemons/com.chef.chef-client.plist')
    end

    it 'reloads the launch daemon' do
      expect(chef_run).to start_macosx_service('com.chef.chef-client')
    end

    it 'restarts the service when daemon is changed' do
      expect(chef_run.template('/Library/LaunchDaemons/com.chef.chef-client.plist')).to notify('macosx_service[com.chef.chef-client]').to(:restart)
    end
  end
end

describe 'chef-client::launchd_service' do
  context 'when self-update attribute is false' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'mac_os_x') do |node|
        node.normal['chef_client']['launchd_self-update'] = false
      end.converge(described_recipe)
    end

    it 'creates the launch daemon' do
      expect(chef_run).to create_template('/Library/LaunchDaemons/com.chef.chef-client.plist')
    end

    it 'reloads the launch daemon' do
      expect(chef_run).to start_macosx_service('com.chef.chef-client')
    end

    it 'does not restart the service when daemon is changed' do
      expect(chef_run.template('/Library/LaunchDaemons/com.chef.chef-client.plist')).to_not notify('macosx_service[com.chef.chef-client]')
    end
  end
end
