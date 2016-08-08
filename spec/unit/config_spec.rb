require 'spec_helper'

describe 'chef-client::config' do
  cached(:chef_run) do
    ChefSpec::ServerRunner.new.converge(described_recipe)
  end

  it 'contains the default chef_server_url setting' do
    expect(chef_run).to render_file('/etc/chef/client.rb') \
      .with_content(/chef_server_url/)
  end

  it 'contains the default validation_client_name setting' do
    expect(chef_run).to render_file('/etc/chef/client.rb') \
      .with_content(/validation_client_name/)
  end

  context 'when Chef::VERSION is 12.4.0 or greater' do
    ## chef-config was introduced in 12.4.0
    ## ohai supports config files in 8.6.0
    before(:each) do
      @chef = ChefSpec.const_get(:Chef)
      @chef_version = @chef.const_get(:VERSION)
      @chef.send(:remove_const, :VERSION)
      @chef.const_set(:VERSION, '12.4.0')
    end

    after(:each) do
      @chef.send(:remove_const, :VERSION)
      @chef.const_set(:VERSION, @chef_version)
    end

    it 'loads config files via ChefConfig::Config.from_file' do
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(/ChefConfig::Config.from_file/)
    end
  end

  context 'when Chef::VERSION is 12.3.0 or earlier' do
    before(:each) do
      @chef = ChefSpec.const_get(:Chef)
      @chef_version = @chef.const_get(:VERSION)
      @chef.send(:remove_const, :VERSION)
      @chef.const_set(:VERSION, '12.3.0')
    end

    after(:each) do
      @chef.send(:remove_const, :VERSION)
      @chef.const_set(:VERSION, @chef_version)
    end

    it 'loads config files via Chef::Config.from_file' do
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(/Chef::Config.from_file/)
    end
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

  let(:template) { chef_run.template('/etc/chef/client.rb') }

  it 'notifies the client to reload' do
    expect(template).to notify('ruby_block[reload_client_config]')
  end

  it 'reloads the client config' do
    expect(chef_run).to_not run_ruby_block('reload_client_config')
  end

  context 'Custom Attributes' do
    cached(:chef_run) do
      ChefSpec::ServerRunner.new do |node|
        node.set['ohai']['disabled_plugins'] = [:passwd, 'dmi']
        node.set['ohai']['plugin_path'] = '/etc/chef/ohai_plugins'
        node.set['chef_client']['config']['log_level'] = ':debug'
        node.set['chef_client']['config']['ssl_verify_mode'] = ':verify_none'
        node.set['chef_client']['config']['exception_handlers'] = [{ class: 'SimpleReport::UpdatedResources', arguments: [] }]
        node.set['chef_client']['config']['report_handlers'] = [{ class: 'SimpleReport::UpdatedResources', arguments: [] }]
        node.set['chef_client']['config']['start_handlers'] = [{ class: 'SimpleReport::UpdatedResources', arguments: [] }]
        node.set['chef_client']['config']['http_proxy'] = 'http://proxy.vmware.com:3128'
        node.set['chef_client']['config']['https_proxy'] = 'http://proxy.vmware.com:3128'
        node.set['chef_client']['config']['no_proxy'] = '*.vmware.com,10.*'
        node.set['chef_client']['load_gems']['chef-handler-updated-resources']['require_name'] = 'chef/handler/updated_resources'
        node.set['chef_client']['reload_config'] = false
      end.converge(described_recipe)
    end

    it 'disables ohai 6 & 7 plugins' do
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(/ohai.disabled_plugins =\s+\[:passwd,"dmi"\]/)
    end

    it 'specifies an ohai plugin path' do
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(%(ohai.plugin_path << "/etc/chef/ohai_plugins"))
    end

    it 'converts log_level to a symbol' do
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(/^log_level :debug/)
    end

    it 'converts ssl_verify_mode to a symbol' do
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(/^ssl_verify_mode :verify_none/)
    end

    it 'enables exception_handlers' do
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(%(exception_handlers << SimpleReport::UpdatedResources.new))
    end

    it 'requires handler libraries' do
      expect(chef_run).to install_chef_gem('chef-handler-updated-resources')
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(%(\["chef/handler/updated_resources"\].each do |lib|))
    end

    it 'configures an HTTP Proxy' do
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(%r{^http_proxy "http://proxy.vmware.com:3128"})
    end

    it 'configures an HTTPS Proxy' do
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(%r{^https_proxy "http://proxy.vmware.com:3128"})
    end

    it 'configures no_proxy' do
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(/^no_proxy "\*.vmware.com,10.\*"/)
    end
  end
end
