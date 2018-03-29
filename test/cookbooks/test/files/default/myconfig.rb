require 'logutils'

Chef.event_handler do
  on :run_failed do |exception|
    LogUtils::Logger.error("Hit an exception: #{exception.message}")
  end
end
