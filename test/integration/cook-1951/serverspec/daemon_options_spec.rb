require 'serverspec'

set :backend, :exec

describe process('chef-client') do
  its(:args) { should match /-E cook-1951/ }
end
