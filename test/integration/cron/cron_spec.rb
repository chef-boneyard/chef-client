describe command('crontab -u root -l') do
  its(:stdout) { should match /chef-client/ }
end
