describe command('crontab -u root -l') do
  its(:stdout) { should match %r{chef-client} }
end
