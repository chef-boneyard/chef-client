describe command('C:/opscode/chef/embedded/bin/ohai virtualization -c C:/chef/client.rb') do
  its('exit_status') { should eq 0 }
end

describe file('C:/chef/client.rb') do
  its('content') { should match(/ohai.disabled_plugins = \["Mdadm"\]/) }
  its('content') { should match(%r{ohai.plugin_path << "/tmp/kitchen/ohai/plugins"}) }
end
