require 'rubygems'
require 'test/unit'
require 'vcr'
require 'date'
require './models/bbc_schedule'
require './demon'
require 'timecop'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb
end


class DABProviderMock
  attr_accessor :messages

  def initialize
    self.messages = []
  end

  def send_on_air_now!(pid, text)
    send_message!(pid, text, :on_air_now)
  end

  def send_on_air_next!(pid, text)
    send_message!(pid, text, :on_air_next)
  end

  def send_message!(pid, text, type)
    messages << [pid, text, type, DateTime.now]
  end
end

class DemonTest < Test::Unit::TestCase
  def test_load_schedule
    demon = nil
    start_time = DateTime.parse("2011-05-18T00:00:00+01:00")
    dab_mock = DABProviderMock.new

    VCR.use_cassette("demon_test") do
      schedule = BBCSchedule.load(:radio_2, start_time)

      Timecop.freeze(start_time) do
        demon = Demon.new(dab_mock, schedule)
        demon.tick!
      end

      assert_equal(1, dab_mock.messages.length)

      Timecop.freeze(start_time) do
        demon.tick!
      end
      # Avoid resend
      assert_equal(1, dab_mock.messages.length)

      Timecop.freeze(DateTime.parse("2011-05-18T02:00:00+01:00")) do
        demon.tick!
      end

      assert_equal(2, dab_mock.messages.length)
    end
  end
end
