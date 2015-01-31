require 'rubygems'
require 'test/unit'
require 'vcr'
require 'date'
require './models/bbc_schedule'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb
end


class BBCScheduleTest < Test::Unit::TestCase
  def test_make_url
    date = Date.new(2011, 5, 18)
    expected_url = "http://www.bbc.co.uk/radio2/programmes/schedules/2011/5/18.json"
    assert_equal(expected_url, BBCSchedule.make_url(:radio_2, date))
  end

  def test_load_schedule
    VCR.use_cassette("load_schedule_test") do
      date = Date.new(2011, 5, 18)
      schedule = BBCSchedule.load(:radio_2, date)

      assert_equal(16, schedule.broadcasts.length)

      schedule.broadcasts.each { |broadcast|
        assert(!broadcast.pid.nil?)
        assert(!broadcast.text.nil?)
        assert(!broadcast.starts_at.nil?)
      }

      first_broadcast = schedule.broadcasts.first

      assert_equal "p00gv0hg", first_broadcast.pid
      assert_equal "Janice Long - 18/05/2011", first_broadcast.text
    end
  end
end
