config = if os.windows?
           'C:\chef\client.rb'
         else
           '/etc/chef/client.rb'
         end

path = if os.windows?
         'C:\opscode\chef\embedded\bin\ohai.bat'
       else
         '/opt/chef/embedded/bin/ohai'
       end

describe command("#{path} virtualization -c #{config}") do
  its(:exit_status) { should eq(0) }
end

describe file(config) do
  its('content') { should match(/ohai.disabled_plugins = \["Mdadm"\]/) }
  its('content') { should match(/ohai.optional_plugins = \["Passwd"\]/) }
  its('content') { should match(%r{ohai.plugin_path << "/tmp/kitchen/ohai/plugins"}) }
  its('content') { should match(/chef_license "accept-no-persist"/) }
end
