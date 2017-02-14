describe command('/usr/local/etc/rc.d/chef-client status | grep "chef is running"') do
  its(:exit_status) { should eq 0 }
end

describe service('chef-client') do
  it { should be_enabled }
  it { should be_installed }
  it { should be_running }
end
