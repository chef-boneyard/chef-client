require 'spec_helper'

describe 'chef-client::cron' do
  let(:chef_run) do
    ChefSpec::ServerRunner.new do |node|
      # the root_group attribute isn't present in fauxhai data
      node.set['root_group'] = 'root'
    end.converge(described_recipe)
  end

  [
    '/var/run',
    '/var/chef/cache',
    '/var/chef/backup',
    '/var/log/chef',
    '/etc/chef'
  ].each do |dir|
    it "creates #{dir} with the correct attributes" do
      expect(chef_run).to create_directory(dir).with(
        user: 'root',
        group: 'root'
      )
    end
  end

  context 'environmental variables' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |node|
        node.set['chef_client']['cron']['environment_variables'] = 'FOO=BAR'
      end.converge(described_recipe)
    end

    it 'sets the FOO=BAR environment variable' do
      expect(chef_run).to create_cron('chef-client') \
        .with(command: /FOO=BAR.*chef-client/)
    end
  end

  context 'append to log file' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['chef_client']['cron']['append_log'] = true
      end.converge(described_recipe)
    end

    it 'creates a cron job appending to the log' do
      expect(chef_run).to create_cron('chef-client') \
        .with(command: /chef-client >>/)
    end
  end
end
