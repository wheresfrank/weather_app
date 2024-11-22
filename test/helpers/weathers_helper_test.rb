require 'test_helper'

class WeathersHelperTest < ActionView::TestCase
  test 'forecast_date formats date correctly' do
    date_string = '2024-03-20'
    formatted_date = forecast_date(date_string)
    assert_equal 'Wednesday, Mar 20', formatted_date
  end

  test 'forcast_temp formats temperature correctly' do
    assert_equal '75°F', forcast_temp(75.2)
    assert_equal '80°F', forcast_temp(80.0)
    assert_equal '72°F', forcast_temp(72.4)
  end

  test 'air_quality returns correct description' do
    assert_equal 'Good', air_quality(1)
    assert_equal 'Moderate', air_quality(2)
    assert_equal 'Unhealthy for sensitive groups', air_quality(3)
    assert_equal 'Unhealthy', air_quality(4)
    assert_equal 'Very Unhealthy', air_quality(5)
    assert_equal 'Hazardous', air_quality(6)
    assert_equal 'Unknown', air_quality(7)
  end
end