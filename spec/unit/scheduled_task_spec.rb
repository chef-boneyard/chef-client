# Chefspec and windows aren't the best of friends. Running this on a non-windows
# host results in win32ole load errors.

require 'spec_helper'

describe 'chef-client::task' do
  let(:local_system) { instance_double('LocalSystem', account_simple_name: 'system') }
  let(:sid_class) { class_double('Chef::ReservedNames::Win32::Security::SID', LocalSystem: local_system, system_user?: true) }
  let(:node) { runner.node }
  let(:chef_run) { runner.converge(described_recipe) }
  let(:runner) { ChefSpec::SoloRunner.new(platform: 'windows', version: '2012R2', step_into: ['chef_client_scheduled_task']) }

  before do
    # Mock up the environment to behave like Windows running Chef < 16
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('COMSPEC').and_return('cmd')
    stub_const('Chef::ReservedNames::Win32::Security::SID', sid_class)
    node.automatic['chef_client']['bin'] = 'C:/opscode/chef/bin/chef-client'
    allow(Chef::Resource).to receive(:respond_to?).and_call_original
    allow(Chef::Resource).to receive(:respond_to?).with(:chef_version_for_provides).and_return(true)
    allow(Chef::Resource).to receive(:chef_version_for_provides).with('< 16.0').and_return(true)
  end

  context 'when given override attributes' do
    before do
      node.override['chef_client']['task']['start_time'] = '16:10'
      node.override['chef_client']['task']['frequency'] = 'hourly'
      node.override['chef_client']['task']['frequency_modifier'] = 1
      node.override['chef_client']['daemon_options'] = ['-s', '300', '^>', 'NUL', '2^>^&1']
    end

    it 'creates the windows_task resource with desired settings' do
      expect(chef_run).to create_windows_task('chef-client').with(
        command: 'cmd /c "C:/opscode/chef/bin/chef-client -L C:/chef/log/client.log -c C:/chef/client.rb -s 300 ^> NUL 2^>^&1"',
        user: 'SYSTEM',
        frequency: :hourly,
        frequency_modifier: 1,
        start_time: '16:10'
      )
    end
  end

  context 'when configured to use a consistent splay and snap frequency time' do
    let(:now) { Time.new('2021', '4', '15', '16', '7', '12') }
    before do
      node.override['chef_client']['task']['use_consistent_splay'] = true
      node.override['chef_client']['task']['snap_time_to_frequency'] = true
      allow(Time).to receive(:now).and_return(now)
      allow_any_instance_of(Chef::Resource::ChefClientScheduledTask).to receive(:splay_sleep_time).and_return(222)
    end

    it 'creates the windows_task resource with desired settings' do
      expect(chef_run).to create_windows_task('chef-client').with(
                            command: 'cmd /c "C:/windows/system32/windowspowershell/v1.0/powershell.exe Start-Sleep -s 222 && C:/opscode/chef/bin/chef-client -L C:/chef/log/client.log -c C:/chef/client.rb"',
                            start_day: '04/15/2021',
                            start_time: '16:30'
                          )
    end
  end
end
