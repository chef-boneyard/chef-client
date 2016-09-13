require 'spec_helper'

describe 'chef-client::task' do
  context 'when given override attributes' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'windows', version: '2012R2') do |node|
        node.override['chef_client']['task']['start_time'] = 'Tue Sep 13 15:46:33 EDT 2016'
        node.override['chef_client']['task']['user'] = 'system'
        node.override['chef_client']['task']['password'] = 'secret'
        node.override['chef_client']['task']['frequency'] = 'hourly'
        node.override['chef_client']['task']['frequency_modifier'] = 60
      end.converge(described_recipe)
    end

    before(:each) do
      allow(File).to receive(:exists?).and_call_original
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:exists?).with('C:/opscode/chef/bin/chef-client').and_return(true)
      allow_any_instance_of(Chef::Recipe).to receive(:create_directories)
      allow_any_instance_of(Chef::Resource).to receive(:chef_client_service_running)
      allow_any_instance_of(Chef::Recipe).to receive(:root_owner).and_return('owner')
    end

    it 'creates the windows_task resource with desired settings' do
      expect(chef_run).to create_windows_task('chef-client').with(
        command: 'cmd /c " C:/opscode/chef/bin/chef-client -L C:/chef/log/client.log -c C:/chef/client.rb -s 300 ^> NUL 2^>^&1"',
        user: 'system',
        password: 'secret',
        frequency: :hourly,
        frequency_modifier: 60,
        start_time: 'Tue Sep 13 15:46:33 EDT 2016'
      )
    end
  end
end
