require 'serverspec'

set :backend, :exec


describe command('crontab -u root -l') do
  its(:stdout) { should match /\/usr\/bin\/chef-client/ }
end
