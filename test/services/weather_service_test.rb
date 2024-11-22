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
    Rails.cache.clear
  end

  test 'initializes with location' do
    assert_equal '90210', @service.location
  end

  test 'tracks cache status correctly' do
    api_response_json = @api_response.to_json
    
    # Mock Faraday response
    mock_response = Object.new
    def mock_response.status; 200; end
    def mock_response.body; @body; end
    mock_response.instance_variable_set(:@body, api_response_json)

    # Use memory store for testing to ensure caching works as expected
    cache_store = ActiveSupport::Cache::MemoryStore.new
    Rails.stub :cache, cache_store do
      # Stub Faraday.get to return our mock response
      Faraday.stub :get, mock_response do
        # First call - should not be cached
        result1 = @service.get_weather_data
        assert_not @service.cached, "First call should not be cached"
        
        # Second call - should be cached
        result2 = @service.get_weather_data
        assert @service.cached, "Second call should be cached"
        
        # Verify both calls return the same data
        assert_equal result1, result2
      end
    end
  end
end