describe file('/etc/cron.d/chef-client') do
  its('content') { should match(/chef-client/) }
  its('content') { should match(/--run-lock-timeout 0/) }
end
