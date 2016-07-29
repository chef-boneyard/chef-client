describe command('ps aux | grep che[f]') do
  its(:stdout) { should match /chef-client/ }
end
