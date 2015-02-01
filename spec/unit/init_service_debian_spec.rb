require 'spec_helper'

describe 'chef-client::init_service' do

  context 'Debian/Ubuntu' do

    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '12.04') do |node|
        node.set['chef_client']['daemon_options'] = ["-E client-args"]
      end.converge(described_recipe)
    end

    it 'should set -E client-args' do
      expect(chef_run).to render_file("/etc/init.d/chef-client") \
        .with_content(%r{DAEMON_OPTS=".*-E client-args"})
    end

  end

end
