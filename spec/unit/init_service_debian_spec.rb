require 'spec_helper'

describe 'chef-client::init_service' do

  context 'Debian/Ubuntu' do

    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04') do |node|
        node.set['chef_client']['daemon_options'] = ["-E cook-1951"]
      end.converge(described_recipe)
    end

    it 'should set -E cook-1951' do
      expect(chef_run).to render_file("/etc/init.d/chef-client") \
        .with_content(%r{DAEMON_OPTS=".*-E cook-1951"})
    end

  end

end
