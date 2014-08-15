require 'spec_helper'

describe 'chef-client::init_service' do

  os = { platform: 'suse', version: '11.3', conf_dir: 'sysconfig' }

  context os[:platform] do

    let(:chef_run) do
      ChefSpec::Runner.new(platform: os[:platform], version: os[:version]) do |node|
        node.set['chef_client']['daemon_options'] = ["-E cook-1951"]
      end.converge(described_recipe)
    end

    it 'should set -E cook-1951' do
      expect(chef_run).to render_file("/etc/#{os[:conf_dir]}/chef-client") \
        .with_content(%r{OPTIONS="-E cook-1951"})
    end

  end

end
