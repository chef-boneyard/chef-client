require 'spec_helper'

describe 'chef-client::init_service' do

  os = { platform: 'centos', version: '6.5', conf_dir: 'sysconfig' }

  context os[:platform] do

    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: os[:platform], version: os[:version]) do |node|
        node.set['chef_client']['daemon_options'] = ["-E client-args"]
      end.converge(described_recipe)
    end

    it 'should set -E client-args' do
      expect(chef_run).to render_file("/etc/#{os[:conf_dir]}/chef-client") \
        .with_content(%r{OPTIONS="-E client-args"})
    end

  end

end
