describe command('ohai virtualization -c /etc/chef/client.rb') do
  its(:exit_status) { should eq(0) }
end

describe file('/etc/chef/client.rb') do
  its('content') { should match(/ohai.disabled_plugins = \["Mdadm"\]/) }
  its('content') { should match(%r{ohai.plugin_path << "/tmp/kitchen/ohai/plugins"}) }
end
