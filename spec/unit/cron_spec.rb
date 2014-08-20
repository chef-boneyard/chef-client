require 'spec_helper'

describe 'chef-client::cron' do

  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
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

  context 'Custom Attributes' do

    let(:chef_run) do
      ChefSpec::Runner.new do |node|
        node.set['chef_client']['cron']['environment_variables'] = 'FOO=BAR'
      end.converge(described_recipe)
    end

    it 'sets the FOO=BAR environment variable' do
      expect(chef_run).to create_cron('chef-client') \
        .with(command: %r{/bin/sleep \d+; FOO=BAR /usr/bin/chef-client > /dev/null 2>&1})
    end

  end

end
