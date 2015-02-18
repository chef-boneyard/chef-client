require 'serverspec'

set :backend, :exec

describe service('chef-client') do
  it { should be_running }
end

describe file('/etc/service/chef-client/run') do
  it { should be_file }
end
