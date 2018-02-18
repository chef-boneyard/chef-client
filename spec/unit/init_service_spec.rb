require 'spec_helper'

describe 'chef-client::init_service' do
  centos6 = { platform: 'centos', version: '6.9', conf_dir: 'sysconfig' }
  ubuntu = { platform: 'ubuntu', version: '14.04', conf_dir: 'init.d' }
  sles = { platform: 'suse', version: '11.4', conf_dir: 'init.d' }

  context "#{centos6[:platform]} #{centos6[:version]}" do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: centos6[:platform], version: centos6[:version]) do |node|
        node.normal['chef_client']['daemon_options'] = ['-E client-args']
      end.converge(described_recipe)
    end

    it 'should set -E client-args' do
      expect(chef_run).to render_file("/etc/#{centos6[:conf_dir]}/chef-client") \
        .with_content(/OPTIONS="-E client-args"/)
    end
  end

  context "#{ubuntu[:platform]} #{ubuntu[:version]}" do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: ubuntu[:platform], version: ubuntu[:version]) do |node|
        node.normal['chef_client']['daemon_options'] = ['-E client-args']
      end.converge(described_recipe)
    end

    it 'should set -E client-args' do
      expect(chef_run).to render_file("/etc/#{ubuntu[:conf_dir]}/chef-client") \
        .with_content(/DAEMON_OPTS=".*-E client-args"/)
    end
  end

  context "#{sles[:platform]} #{sles[:version]} without daemon options" do
    cached(:chef_run) do
      ChefSpec::ServerRunner.new(platform: sles[:platform], version: sles[:version]) do |node|
        node.normal['ohai']['daemon_options'] = []
      end.converge(described_recipe)
    end

    it 'should not include OPTIONS in chef-client start command' do
      expect(chef_run).not_to render_file("/etc/#{sles[:conf_dir]}/chef-client") \
        .with_content(%r{"\$OPTIONS"})
    end
  end

  context "#{sles[:platform]} #{sles[:version]} with daemon options" do
    cached(:chef_run) do
      ChefSpec::ServerRunner.new(platform: sles[:platform], version: sles[:version]) do |node|
        node.normal['chef_client']['daemon_options'] = ['-E client-args']
      end.converge(described_recipe)
    end

    it 'should include OPTIONS in chef-client start command' do
      expect(chef_run).to render_file("/etc/#{sles[:conf_dir]}/chef-client") \
        .with_content(%r{"\$OPTIONS"})
    end

    it 'should set PIDFILE to /var/run/chef/client.pid' do
      expect(chef_run).to render_file("/etc/#{sles[:conf_dir]}/chef-client") \
        .with_content(%r{PIDFILE-/var/run/chef/client.pid})
    end
  end
end
