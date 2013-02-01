define :arch_service, :client_bin => '/usr/bin/chef-client' do
  template "/etc/rc.d/chef-client" do
    source "rc.d/chef-client.erb"
    mode 0755
    variables(
      :client_bin => params[:client_bin]
    )
    notifies :restart, "service[chef-client]", :delayed
  end

  template "/etc/conf.d/chef-client.conf" do
    source "conf.d/chef-client.conf.erb"
    mode 0644
    notifies :restart, "service[chef-client]", :delayed
  end

  service "chef-client" do
    action [:enable, :start]
  end
end