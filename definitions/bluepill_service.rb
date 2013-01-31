define :bluepill_service do
  directory node["chef_client"]["run_path"] do
    recursive true
    owner "root"
    group root_group
    mode 0755
  end

  include_recipe "bluepill"

  template "#{node["bluepill"]["conf_dir"]}/chef-client.pill" do
    source "chef-client.pill.erb"
    mode 0644
    notifies :restart, "bluepill_service[chef-client]", :delayed
  end

  bluepill_service "chef-client" do
    action [:enable,:load,:start]
  end
end