config = if os.windows?
           'C:\chef\client.rb'
         else
           '/etc/chef/client.rb'
         end

describe file(config) do
  its('content') { should match(/chef_license "accept-no-persist"/) }
end
