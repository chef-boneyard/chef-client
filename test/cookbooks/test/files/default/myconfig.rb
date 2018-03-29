require 'syslog-logger'
require 'syslog'

Logger::Syslog.class_eval do
  attr_accessor :sync, :formatter
end

log_location Chef::Log::Syslog.new('chef-client', ::Syslog::LOG_DAEMON)
