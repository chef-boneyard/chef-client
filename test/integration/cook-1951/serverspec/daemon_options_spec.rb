require 'serverspec'

include Serverspec::Helper::Exec

describe process('chef-client') do
  its(:args) { should match /-E cook-1951/ }
end
