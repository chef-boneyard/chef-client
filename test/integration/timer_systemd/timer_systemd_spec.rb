describe systemd_service('chef-client.timer') do
  it { should be_enabled }
  it { should be_running }
end

describe command('systemctl show -p Triggers chef-client.timer') do
  its('stdout') { should match 'Triggers=chef-client.service' }
end

describe command('systemctl show -p NextElapseUSecMonotonic chef-client.timer') do
  its('stdout') { should_not match 'infinity' }
end

describe file('/etc/systemd/system/chef-client.timer') do
  its('content') { should match 'OnBootSec = 1min' }
  its('content') { should match 'OnUnitInactiveSec = 1800sec' }
  its('content') { should match 'RandomizedDelaySec = 300sec' }
end
