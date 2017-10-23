describe processes('chef-client') do
  it { should exist }
end

describe service('chef-client') do
  it { should be_enabled }
  it { should be_installed }
  it { should be_running }
end
