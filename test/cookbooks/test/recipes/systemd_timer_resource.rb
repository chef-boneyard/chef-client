chef_client_systemd_timer 'schedule chef-client to run as cron job' do
  accept_chef_license true
  daemon_options ['--run-lock-timeout 0']
  environment 'FOO' => '1', 'BAR' => '2'
  nice 19
  cpu_scheduling_policy 'idle'
  cpu_scheduling_priority 1
  io_scheduling_class 'idle'
  io_scheduling_priority 7
end

chef_client_systemd_timer 'a timer that does not exist' do
  action :remove
end
