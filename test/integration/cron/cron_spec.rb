if os.linux?
  describe file('/etc/cron.d/chef-client') do
    its('content') { should match(/chef-client/) }
    its('content') { should match(/^FOO=bar$/) }
    its('content') { should match(%r{> /dev/null}) }
  end
else
  describe command('crontab -u root -l') do
    its(:stdout) { should match(/chef-client/) }
  end
end
