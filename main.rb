require "date"
require "./demon"
require "./models/bbc_schedule"
require "net/http"

all_schedules_for_today = BBCSchedule.all_schedules(DateTime.now)


class DABProviderStdout
  def send_on_air_now!(pid, text)
    send_message!(pid, text, :on_air_now)
  end

  def send_on_air_next!(pid, text)
    send_message!(pid, text, :on_air_next)
  end

  def send_message!(pid, text, type)
    p [pid, text, type, DateTime.now]
  end
end

demon = Demon.new(DABProviderStdout.new, all_schedules_for_today)

puts "Starting Demon..."


loop do
  demon.tick!
  sleep (0.1)
end
