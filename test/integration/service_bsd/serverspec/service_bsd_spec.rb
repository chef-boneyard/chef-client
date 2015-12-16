require 'serverspec'

set :backend, :exec

describe command('/etc/rc.d/chef-client status | grep "chef is running"') do
  its(:exit_status) { should eq 0 }
end
