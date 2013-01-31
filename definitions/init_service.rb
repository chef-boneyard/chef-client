define :init_service, :client_bin => '/usr/bin/chef-client' do
  #argh?
  dist_dir, conf_dir = value_for_platform_family(
    ["debian"] => ["debian", "default"],
    ["fedora"] => ["redhat", "sysconfig"],
    ["rhel"] => ["redhat", "sysconfig"],
    ["suse"] => ["suse", "sysconfig"]
  )

  template "/etc/init.d/chef-client" do
    source "#{dist_dir}/init.d/chef-client.erb"
    mode 0755
    variables(
      :client_bin => params[:client_bin]
    )
    notifies :restart, "service[chef-client]", :delayed
  end

  template "/etc/#{conf_dir}/chef-client" do
    source "#{dist_dir}/#{conf_dir}/chef-client.erb"
    mode 0644
    notifies :restart, "service[chef-client]", :delayed
  end

  service "chef-client" do
    supports :status => true, :restart => true
    action :enable
  end


end