require 'serverspec'

include Serverspec::Helper::Exec

describe service('chef-client') do
  it { should be_running }
end
