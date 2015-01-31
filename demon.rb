class Demon
  attr_accessor :dab
  attr_accessor :pending

  def initialize(dab, schedule)
    self.dab = dab
    self.pending = schedule.broadcasts
  end

  def tick!
    if pending.empty?
      fetch_next_day!
    end
    nowish = DateTime.now.to_time.to_i

    on_air_now = pending.select { |broadcast|
      (broadcast.starts_at.to_time.to_i - 60) < nowish &&
        (broadcast.starts_at.to_time.to_i + 60) > nowish
    }

    on_air_now.map { |broadcast|
      dab.send_on_air_now!(broadcast.pid, broadcast.text)
    }

    self.pending = self.pending - on_air_now
  end

  def fetch_next_day!
    raise "Not Implemented"
  end
end
