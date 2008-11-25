require 'test/unit'
require 'crondog'

class Jobs < Crondog::JobList
  every.minute "check email" do
    # check email
  end
  
  every(5).minutes "ping production server" do
    `ping 127.0.0.1`
  end
  
  at(7).minutes "report the weather" do
    # report the weather
  end
  
  on(1, 3, 5).weekdays "run a mile" do
    # run a mile
  end

  from(9).to(17).hours "sit at desk" do
    # sit at my desk
  end

  every(10).minutes.during(12).month "hear christmas music" do
    # hear christmas music
  end
  
  on("Tuesday").at(11).hours "talk to Morrie" do
    # I'm a dick
  end

  during "April", "bring an umbrella" do
    p "Bring an umbrella!"
  end

  at(10).hours.and(0).minutes "sum 1 through 5" do
    (1..5).inject {|sum, i| sum + i }
  end
end

class CrondogTest < Test::Unit::TestCase
  def test_should_have_all_wildcards_by_default
    assert_equal "* * * * * check_email.rb", Jobs.first.to_s
  end
  
  def test_should_set_wildcard_period
    assert_equal "*/5 * * * * ping_production_server.rb", Jobs[1].to_s
  end
  
  def test_should_set_specific_time
    assert_equal "7 * * * * report_the_weather.rb", Jobs[2].to_s
  end
  
  def test_should_set_multiple_times
    assert_equal "* * * * 1,3,5 run_a_mile.rb", Jobs[3].to_s
  end

  def test_should_set_range_of_times
    assert_equal "* 9-17 * * * sit_at_desk.rb", Jobs[4].to_s
  end

  def test_should_be_chainable
    assert_equal "*/10 * * 12 * hear_christmas_music.rb", Jobs[5].to_s
  end
  
  def test_should_accept_literal_day_names
    assert_equal "* 11 * * 2 talk_to_morrie.rb", Jobs[6].to_s
  end

  def test_should_accept_literal_month_name
    assert_equal "* * * 4 * bring_an_umbrella.rb", Jobs[7].to_s
    assert_equal 'p("Bring an umbrella!")', Jobs[7].task
  end

  def test_should_chain_with_and
    assert_equal "0 10 * * * sum_1_through_5.rb", Jobs.last.to_s
  end
  
  def test_should_store_block_as_string
    assert_equal "(1..5).inject { |sum, i| (sum + i) }", Jobs.last.task
  end
  
  def test_stored_block_should_be_executable
    assert_equal 15, eval(Jobs.last.task)
  end

  def test_should_write_to_file
    Jobs.last.to_file
    assert_equal "(1..5).inject { |sum, i| (sum + i) }",
      File.open("sum_1_through_5.rb").read.strip
    File.delete("sum_1_through_5.rb")
  end

  def test_should_display_crontab
    tab = Jobs.crontab
    assert_equal 9, tab.split("\n").size
    assert_match /check_email/, tab
    assert_match /sum_1_through_5/, tab
  end
end