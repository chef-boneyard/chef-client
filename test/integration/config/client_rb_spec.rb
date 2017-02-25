config = if os.windows?
           'C:\chef\client.rb'
         else
           '/etc/chef/client.rb'
         end

describe command("ohai virtualization -c #{config}") do
  its(:exit_status) { should eq(0) }
end

describe file(config) do
  its('content') { should match(/ohai.disabled_plugins = \["Mdadm"\]/) }
  its('content') { should match(%r{ohai.plugin_path << "/tmp/kitchen/ohai/plugins"}) }
end
