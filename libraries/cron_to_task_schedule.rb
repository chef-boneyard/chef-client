module Opscode
  module ChefClient
    module Helpers
      CRON_REGEXP = /^(?<wild>\*)$|^(?<interval>\*\/)?(?<num>\d{1,2})$/

      # convert cron minute and hour schedules to something windows task scheduler understands
      # === Returns
      # array:: [frequency, frequency_modifier, start_time]. start_time may be nil
      def cron_to_task_schedule(cron_minutes, cron_hours, start_after = Time.now)
        minute_match = CRON_REGEXP.match(cron_minutes)
        hour_match = CRON_REGEXP.match(cron_hours)

        Chef::Application.fatal! "Could not determine scheduled task schedule from cron min: '#{cron_minutes}', hr: '#{cron_hours}'" unless minute_match && hour_match

        if minute_match['wild']
          # every minute
          unless hour_match['wild']
            Chef::Application.fatal! "Scheduled task frequency does not currently support every minute of specific hour. hr: '#{cron_hours}'"
          end
          [:minute, 1, nil]
        elsif minute_match['interval']
          # every N minutes of every hour
          interval = 60/minute_match['num'].to_i

          unless hour_match['wild']
            Chef::Application.fatal! "Scheduled task frequency does not currently support every #{interval} minutes of specific hour. hr: '#{cron_hours}'"
          end

          start_time = start_after.dup
          until start_time.min % interval == 0
            start_time += 60
          end

          [:minute, interval, start_time]
        elsif hour_match['wild']
          # specific minute of every hour
          start_time = start_after.dup
          if start_time.min < minute_match['num'].to_i
            start_time += 60*(minute_match['num'].to_i - start_time.min)
          elsif start_time.min > minute_match['num'].to_i
            start_time += 60*(60 + minute_match['num'].to_i - start_time.min)
          end
          [:hourly, 1, start_time]
        elsif hour_match['interval']
          # specific minute of every N hours
          interval = 24/hour_match['num'].to_i

          start_time = start_after.dup
          if start_time.min < minute_match['num'].to_i
            start_time += 60*(minute_match['num'].to_i - start_time.min)
          elsif start_time.min > minute_match['num'].to_i
            start_time += 60*(60 + minute_match['num'].to_i - start_time.min)
          end

          until start_time.hour % interval == 0
            start_time += 60*60
          end

          [:hourly, interval, start_time]
        else
          # specific hour and minute of every day
          [:daily, 1, Time.new(start_after.year, start_after.month, start_after.day, hour_match['num'], minute_match['num'])]
        end
      end

      module_function :cron_to_task_schedule
    end
  end
end
