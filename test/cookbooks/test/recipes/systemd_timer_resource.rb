chef_client_systemd_timer 'schedule chef-client to run as cron job' do
  daemon_options ['--run-lock-timeout 0', '--chef-license accept']
end
