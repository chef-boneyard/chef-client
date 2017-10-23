describe command('C:/opscode/chef/embedded/bin/ohai virtualization -c C:/chef/client.rb') do
  its('exit_status') { should eq 0 }
end

describe file('C:/chef/client.rb') do
  its('content') { should match(/ohai.disabled_plugins = \["Mdadm"\]/) }
  its('content') { should match(%r{ohai.plugin_path << "/tmp/kitchen/ohai/plugins"}) }
end

describe windows_task('chef-client') do
  it { should be_enabled }
  its('run_as_user') { should eq 'SYSTEM' }
  its('task_to_run') { should match 'cmd /c C:/opscode/chef/bin/chef-client -L C:/chef/log/client.log -c C:/chef/client.rb -s 300' }
end
