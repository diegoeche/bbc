require 'json'

class BBCSchedule
  SOURCES = {
    :radio_2          => "http://www.bbc.co.uk/radio2/programmes/schedules",
    :live_sport_extra => "http://www.bbc.co.uk/5livesportsextra/programmes/schedules",
    :world_service    => "http://www.bbc.co.uk/worldserviceradio/programmes/schedules"
  }

  attr_accessor :broadcasts

  def initialize(broadcasts)
    self.broadcasts = broadcasts
  end

  def self.load(source, date)
    url = make_url(source, date)
    response = Net::HTTP.get_response(URI(url))
    BBCSchedule.from_json(JSON.parse(response.body))
  end

  def self.all_schedules(date)
    BBCSchedule.new(
      SOURCES.keys.map { |source| BBCSchedule.load(source, date).broadcasts }.flatten
    )
  end

  def self.from_json(json)
    broadcasts = json["schedule"]["day"]["broadcasts"].map { |broadcast_json|
      display_titles = broadcast_json["programme"]["display_titles"]
      start_date = DateTime.parse(broadcast_json["start"])
      text = [display_titles["title"], display_titles["subtitle"]].join(" - ")

      Broadcast.new(broadcast_json["pid"], text, start_date)
    }

    BBCSchedule.new(broadcasts)
  end

  def self.make_url(source, date)
    source = SOURCES[source]
    "#{source}/#{date.year}/#{date.month}/#{date.day}.json"
  end
end


class Broadcast
  attr_accessor :pid
  attr_accessor :text
  attr_accessor :starts_at

  def initialize(pid, text, starts)
    self.pid = pid
    self.text = text
    self.starts_at = starts
  end
end
