describe command('crontab -u root -l') do
  its(:stdout) { should match(/chef-client/) }
  its(:stdout) { should match(/--run-lock-timeout 0/) }
end
