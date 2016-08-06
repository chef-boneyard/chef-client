describe command('ohai virtualization -c /etc/chef/client.rb') do
  its(:exit_status) { should eq(0) }
end
