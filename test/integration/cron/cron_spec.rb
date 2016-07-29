describe command('crontab -u root -l') do
  its(:stdout) { should match %r{/usr/bin/chef-client} }
end
