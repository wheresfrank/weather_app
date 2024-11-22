require 'test_helper'

class WeatherServiceTest < ActiveSupport::TestCase
  setup do
    @service = WeatherService.new('90210')
    @api_response = {
      'location' => {
        'name' => 'Beverly Hills'
      },
      'forecast' => {
        'forecastday' => [
          {
            'date' => '2024-03-20',
            'day' => {
              'maxtemp_f' => 75.2,
              'mintemp_f' => 60.8,
              'condition' => {
                'text' => 'Sunny',
                'icon' => '//cdn.weatherapi.com/weather/64x64/day/113.png'
              },
              'daily_chance_of_rain' => 20,
              'air_quality' => {
                'us-epa-index' => 1
              }
            }
          }
        ]
      }
    }
  end

  test 'initializes with zip code' do
    assert_equal '90210', @service.instance_variable_get(:@zip_code)
  end

  test 'successful API response returns formatted weather data' do
    mock_response = Minitest::Mock.new
    mock_response.expect :status, 200
    mock_response.expect :body, @api_response.to_json

    Faraday.stub :get, mock_response do
      result = @service.get_weather_data
      
      assert_equal 'Beverly Hills', result[:location]
      assert_equal 1, result[:forecast].length
      
      forecast = result[:forecast].first
      assert_equal '2024-03-20', forecast[:date]
      assert_equal 75.2, forecast[:max_temp_f]
      assert_equal 20, forecast[:chance_of_rain]
      assert_equal 1, forecast[:air_quality]
    end
  end

  test 'failed API response returns nil' do
    mock_response = Minitest::Mock.new
    mock_response.expect :status, 404
    
    Faraday.stub :get, mock_response do
      result = @service.get_weather_data
      assert_nil result
    end
  end
end