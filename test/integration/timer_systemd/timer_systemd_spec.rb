control 'timer is active' do
  describe systemd_service('chef-client.timer') do
    it { should be_enabled }
    it { should be_running }
  end
end

control 'has expected unit content' do
  describe file('/etc/systemd/system/chef-client.timer') do
    its('content') { should match 'OnBootSec = 1min' }
    its('content') { should match 'OnUnitInactiveSec = 1800sec' }
    its('content') { should match 'RandomizedDelaySec = 300sec' }
  end
end

control 'timer targets service unit' do
  describe command('systemctl show -p Triggers chef-client.timer') do
    its('stdout') { should match 'Triggers=chef-client.service' }
  end
end

control 'schedules trigger on-boot' do
  describe command('systemctl show -p NextElapseUSecMonotonic chef-client.timer') do
    before { sleep 5 }
    its('stdout') { should_not match 'NextElapseUSecMonotonic=infinity' }
  end
end
