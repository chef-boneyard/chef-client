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
        .with(command: %r{FOO=BAR.*chef-client})
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
        .with(command: %r{chef-client >>})
    end

  end

  context 'daemon options in cron' do

    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu', version: '12.04'
      ) do |node|
        node.set['chef_client']['daemon_options'] = %w(--run-lock-timeout 900)
      end.converge(described_recipe)
    end

    it 'creates a cronjob with the daemon options' do
      expect(chef_run).to create_cron('chef-client') \
        .with(command: %r{--run-lock-timeout 900})
    end

    it 'creates a stand-in service starter without the daemon options' do
      starter = chef_run.template('/etc/init.d/chef-client')
      expect(starter.variables[:client_bin]) \
        .not_to match(/--run-lock-timeout 900/)
    end

  end

end
