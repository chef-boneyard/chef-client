require 'serverspec'

set :backend, :exec

describe command('ohai kernel -c /etc/chef/client.rb') do
  its(:exit_status) { should eq(0) }
end
