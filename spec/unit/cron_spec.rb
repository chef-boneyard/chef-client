require 'spec_helper'

describe 'chef-client::cron' do
  cached(:chef_run) { ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04').converge(described_recipe) }

  [
    '/var/run/chef',
    '/var/cache/chef',
    '/var/cache/chef',
    '/var/log/chef',
    '/etc/chef',
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
        node.normal['chef_client']['cron']['environment_variables'] = 'FOO=BAR'
        node.normal['chef_client']['cron']['append_log'] = true
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

  context 'when the chef-client process priority is set' do
    cached(:redhat_chef_run) do
      ChefSpec::ServerRunner.new(platform: 'redhat', version: '7.3') do |node|
        node.normal['chef_client']['cron']['priority'] = 19
      end.converge(described_recipe)
    end

    cached(:invalid_priority_chef_run) do
      ChefSpec::ServerRunner.new(platform: 'redhat', version: '7.3') do |node|
        node.normal['chef_client']['cron']['priority'] = 42
      end.converge(described_recipe)
    end

    cached(:string_but_valid_chef_run) do
      ChefSpec::ServerRunner.new(platform: 'redhat', version: '7.3') do |node|
        node.normal['chef_client']['cron']['priority'] = '-5'
      end.converge(described_recipe)
    end

    cached(:string_but_invalid_chef_run) do
      ChefSpec::ServerRunner.new(platform: 'redhat', version: '7.3') do |node|
        node.normal['chef_client']['cron']['priority'] = '123'
      end.converge(described_recipe)
    end

    cached(:gobbledeegook_chef_run) do
      ChefSpec::ServerRunner.new(platform: 'redhat', version: '7.3') do |node|
        node.normal['chef_client']['cron']['priority'] = 'hibbitydibbity-123'
      end.converge(described_recipe)
    end

    it 'creates a cron job with a prioritized chef-client with an in-bounds priority' do
      expect(redhat_chef_run).to create_cron('chef-client') \
        .with(command: /nice -n 19 .*chef-client/)
    end

    it 'creates a cron job with a non-prioritized chef-client with an out-of-bounds priority' do
      expect(invalid_priority_chef_run).to create_cron('chef-client') \
        .with(command: /sleep \d+; .*chef-client/)
    end

    it 'creates a cron job with a prioritized chef-client with an in-bounds priority (string)' do
      expect(string_but_valid_chef_run).to create_cron('chef-client') \
        .with(command: /nice -n -5 .*chef-client/)
    end

    it 'creates a cron job with a non-prioritized chef-client with an out-of-bounds priority (string)' do
      expect(string_but_invalid_chef_run).to create_cron('chef-client') \
        .with(command: /sleep \d+; .*chef-client/)
    end

    it 'creates a cron job with a non-prioritized chef-client with a garbled string value' do
      expect(gobbledeegook_chef_run).to create_cron('chef-client') \
        .with(command: /sleep \d+; .*chef-client/)
    end
  end
end
