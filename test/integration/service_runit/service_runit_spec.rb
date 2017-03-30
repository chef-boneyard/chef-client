describe command('ps aux | grep che[f]') do
  its(:stdout) { should match(/chef-client/) }
end

describe file('/etc/service/chef-client/run') do
  it { should be_file }
end

describe service('chef-client') do
  it { should be_enabled }
  it { should be_installed }
  it { should be_running }
end
