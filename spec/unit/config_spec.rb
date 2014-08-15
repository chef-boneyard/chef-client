require 'spec_helper'

describe 'chef-client::config' do

  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'contains the default chef_server_url setting' do
    expect(chef_run).to render_file('/etc/chef/client.rb') \
      .with_content(%r{chef_server_url})
  end

  it 'contains the default validation_client_name setting' do
    expect(chef_run).to render_file('/etc/chef/client.rb') \
      .with_content(%r{validation_client_name})
  end

  [
    '/var/run',
    '/var/chef/cache',
    '/var/chef/backup',
    '/var/log/chef',
    '/etc/chef',
    '/etc/chef/client.d'
  ].each do |dir|
    it "contains #{dir} directory" do
      expect(chef_run).to create_directory(dir)
    end
  end

  it 'reloads the client config' do
    expect(chef_run).to_not run_ruby_block('reload_client_config')
  end

  context 'Custom Attributes' do

    let(:chef_run) do
      ChefSpec::Runner.new do |node|
        node.set['ohai']['disabled_plugins'] = [:passwd, "dmi"]
        node.set['chef_client']['config']['log_level'] = ":debug"
        node.set['chef_client']['config']['ssl_verify_mode'] = ":verify_peer"
        node.set['chef_client']['config']['exception_handlers'] = [{class: "SimpleReport::UpdatedResources", arguments: []}]
        node.set['chef_client']['config']['report_handlers'] = [{class: "SimpleReport::UpdatedResources", arguments: []}]
        node.set['chef_client']['config']['start_handlers'] = [{class: "SimpleReport::UpdatedResources", arguments: []}]
        node.set['chef_client']['load_gems']['chef-handler-updated-resources']['require_name'] = "chef/handler/updated_resources"
      end.converge(described_recipe)
    end

    it 'disables ohai 6 & 7 plugins' do
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(%r{Ohai::Config\[:disabled_plugins\] =\s+\[:passwd,"dmi"\]})
    end

    it 'converts log_level to a symbol' do
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(%r{^log_level :debug})
    end

    it 'converts ssl_verify_mode to a symbol' do
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(%r{^ssl_verify_mode :verify_peer})
    end

    it 'enables exception_handlers' do
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(%{exception_handlers << SimpleReport::UpdatedResources.new})
    end

    it 'requires handler libraries' do
      expect(chef_run).to install_chef_gem('chef-handler-updated-resources')
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(%{\["chef/handler/updated_resources"\].each do |lib|})
    end


  end


end
