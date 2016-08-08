require 'spec_helper'

describe 'chef-client::cron' do
  cached(:chef_run) { ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04').converge(described_recipe) }

  [
    '/var/run/chef',
    '/var/cache/chef',
    '/var/cache/chef',
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

  context 'environmental variables and append_log' do
    cached(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04') do |node|
        node.set['chef_client']['cron']['environment_variables'] = 'FOO=BAR'
        node.set['chef_client']['cron']['append_log'] = true
      end.converge(described_recipe)
    end

    it 'sets the FOO=BAR environment variable' do
      expect(chef_run).to create_cron('chef-client') \
        .with(command: /FOO=BAR.*chef-client/)
    end

    it 'creates a cron job appending to the log' do
      expect(chef_run).to create_cron('chef-client') \
        .with(command: /chef-client >>/)
    end
  end
end
