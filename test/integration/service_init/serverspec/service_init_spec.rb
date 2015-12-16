require 'serverspec'

set :backend, :exec

# the service check in serverspec fails if the service command isn't available
describe command('/etc/init.d/chef-client status | grep running') do
  its(:exit_status) { should eq 0 }
end
