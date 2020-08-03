require 'spec_helper'

describe 'chef-client::config' do
  cached(:chef_run) do
    ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '18.04').converge(described_recipe)
  end

  it 'does not accept the chef license by default' do
    expect(chef_run).to render_file('/etc/chef/client.rb') \
      .with_content { |content| expect(content).to_not match(/chef_license/) }
  end

  it 'contains the default chef_server_url setting' do
    expect(chef_run).to render_file('/etc/chef/client.rb') \
      .with_content(/chef_server_url/)
  end

  it 'contains the default validation_client_name setting' do
    expect(chef_run).to render_file('/etc/chef/client.rb') \
      .with_content(/validation_client_name/)
  end

  [
    '/var/run/chef',
    # '/var/cache/chef',
    '/var/lib/chef',
    '/var/log/chef',
    '/etc/chef',
    '/etc/chef/client.d',
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
      ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '18.04') do |node|
        node.normal['chef_client']['chef_license'] = 'accept-no-persist'
        node.normal['ohai']['disabled_plugins'] = [:passwd, 'dmi']
        node.normal['ohai']['optional_plugins'] = [:mdadm]
        node.normal['ohai']['plugin_path'] = '/etc/chef/ohai_plugins'
        node.normal['chef_client']['config']['log_level'] = ':debug'
        node.normal['chef_client']['config']['log_location'] = '/dev/null'
        node.normal['chef_client']['config']['ssl_verify_mode'] = ':verify_none'
        node.normal['chef_client']['config']['exception_handlers'] = [{ class: 'SimpleReport::UpdatedResources', arguments: [] }]
        node.normal['chef_client']['config']['report_handlers'] = [{ class: 'SimpleReport::UpdatedResources', arguments: [] }]
        node.normal['chef_client']['config']['start_handlers'] = [{ class: 'SimpleReport::UpdatedResources', arguments: [] }]
        node.normal['chef_client']['config']['http_proxy'] = 'http://proxy.vmware.com:3128'
        node.normal['chef_client']['config']['https_proxy'] = 'http://proxy.vmware.com:3128'
        node.normal['chef_client']['config']['no_proxy'] = '*.vmware.com,10.*'
        node.normal['chef_client']['load_gems']['chef-handler-updated-resources']['require_name'] = 'chef/handler/updated_resources'
        node.normal['chef_client']['reload_config'] = false
      end.converge(described_recipe)
    end

    it 'accepts the chef license' do
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(/chef_license "accept-no-persist"/)
    end

    it 'disables ohai 6 & 7 plugins' do
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(/ohai.disabled_plugins =\s+\[:passwd,"dmi"\]/)
    end

    it 'enables ohai 6 & 7 plugins' do
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(/ohai.optional_plugins =\s+\[:mdadm\]/)
    end

    it 'specifies an ohai plugin path' do
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(%(ohai.plugin_path << "/etc/chef/ohai_plugins"))
    end

    it 'converts log_level to a symbol' do
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(/^log_level :debug/)
    end

    it 'renders log_location with quotes' do
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(%r{^log_location "/dev/null"$})
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

  context 'STDOUT Log Location' do
    cached(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '18.04') do |node|
        node.normal['chef_client']['config']['log_level'] = ':debug'
        node.normal['chef_client']['config']['log_location'] = 'STDOUT'
        node.normal['chef_client']['config']['ssl_verify_mode'] = ':verify_none'
      end.converge(described_recipe)
    end

    it 'renders log_location without quotes' do
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(/^log_location STDOUT$/)
    end
  end

  context 'Symbol-ized Log Location' do
    cached(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '18.04') do |node|
        node.normal['chef_client']['config']['log_level'] = ':debug'
        node.normal['chef_client']['config']['log_location'] = :syslog
        node.normal['chef_client']['config']['ssl_verify_mode'] = ':verify_none'
      end.converge(described_recipe)
    end

    it 'renders log_location as a symbol' do
      expect(chef_run).to render_file('/etc/chef/client.rb') \
        .with_content(/^log_location :syslog$/)
    end
  end

  context 'Stringy Symbol-ized Log Location' do
    # use let instead of cached because we're going to change an attribute
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04') do |node|
        node.normal['chef_client']['config']['log_level'] = ':debug'
        node.normal['chef_client']['config']['log_location'] = log_location
        node.normal['chef_client']['config']['ssl_verify_mode'] = ':verify_none'
      end.converge(described_recipe)
    end

    %w(:syslog syslog).each do |string|
      context "with #{string}" do
        let(:log_location) { string }

        it 'renders log_location as a symbol' do
          expect(chef_run).to render_file('/etc/chef/client.rb') \
            .with_content(/^log_location :syslog$/)
        end
      end
    end

    %w(:win_evt win_evt).each do |string|
      context "with #{string}" do
        let(:log_location) { string }

        it 'renders log_location as a symbol' do
          expect(chef_run).to render_file('/etc/chef/client.rb') \
            .with_content(/^log_location :win_evt$/)
        end
      end
    end
  end
end
