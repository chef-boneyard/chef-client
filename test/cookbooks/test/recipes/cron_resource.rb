chef_client_cron 'schedule chef-client to run as cron job' do
  daemon_options ['--run-lock-timeout 0']
end
