# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Learn more: http://github.com/javan/whenever

set :cron_log, "#{RAILS_ROOT}/log/cron_log.log"
set :server_type, nil

case server_type
when 'thin'
  every 1.day, :at => "3:37 am" do
    command "thin restart -C #{RAILS_ROOT}/config/thin.yml"
  end

when 'unicorn'
  every 1.day, :at => "3:37 am" do
    command "[ -f #{RAILS_ROOT}/tmp/pids/unicorn.pid ] && kill -HUP `cat #{RAILS_ROOT}/tmp/pids/unicorn.pid`"
  end
end

every 8.hours, :at => 37 do
  rake "ts:in"
end

every :reboot do
  rake 'ts:start'
end
