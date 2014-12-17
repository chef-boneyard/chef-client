require 'serverspec'

set :backend, :exec

describe service('chef-client') do
  it { should be_running }
end
