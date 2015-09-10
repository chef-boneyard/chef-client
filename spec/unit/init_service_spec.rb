require 'spec_helper'

describe 'chef-client::init_service' do
  centos5 = { platform: 'centos', version: '5.10', conf_dir: 'sysconfig' }
  centos6 = { platform: 'centos', version: '6.5', conf_dir: 'sysconfig' }
  ubuntu = { platform: 'ubuntu', version: '12.04', conf_dir: 'init.d' }
  opensuse = { platform: 'suse', version: '11.3', conf_dir: 'sysconfig' }

  context "#{centos5[:platform]} #{centos5[:version]}" do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: centos5[:platform], version: centos5[:version]) do |node|
        node.set['chef_client']['daemon_options'] = ['-E client-args']
      end.converge(described_recipe)
    end

    it 'should set -E client-args' do
      expect(chef_run).to render_file("/etc/#{centos5[:conf_dir]}/chef-client") \
        .with_content(/OPTIONS="-E client-args"/)
    end
  end

  context "#{centos6[:platform]} #{centos6[:version]}" do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: centos6[:platform], version: centos6[:version]) do |node|
        node.set['chef_client']['daemon_options'] = ['-E client-args']
      end.converge(described_recipe)
    end

    it 'should set -E client-args' do
      expect(chef_run).to render_file("/etc/#{centos6[:conf_dir]}/chef-client") \
        .with_content(/OPTIONS="-E client-args"/)
    end
  end

  context "#{opensuse[:platform]} #{opensuse[:version]}" do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: opensuse[:platform], version: opensuse[:version]) do |node|
        node.set['chef_client']['daemon_options'] = ['-E client-args']
      end.converge(described_recipe)
    end

    it 'should set -E client-args' do
      expect(chef_run).to render_file("/etc/#{opensuse[:conf_dir]}/chef-client") \
        .with_content(/OPTIONS="-E client-args"/)
    end
  end

  context "#{ubuntu[:platform]} #{ubuntu[:version]}" do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: ubuntu[:platform], version: ubuntu[:version]) do |node|
        node.set['chef_client']['daemon_options'] = ['-E client-args']
      end.converge(described_recipe)
    end

    it 'should set -E client-args' do
      expect(chef_run).to render_file("/etc/#{ubuntu[:conf_dir]}/chef-client") \
        .with_content(/DAEMON_OPTS=".*-E client-args"/)
    end
  end
end
