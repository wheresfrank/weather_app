require "test_helper"

class WeathersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get weathers_url
    assert_response :success
    assert_select "h1", "Weather Forecast"
  end

  test "should get index with zip code" do
    mock_weather_data = {
      location: "Beverly Hills",
      forecast: [
        {
          date: "2024-03-20",
          max_temp_f: 75.2,
          min_temp_f: 60.8,
          condition: "Sunny",
          icon: "//cdn.weatherapi.com/weather/64x64/day/113.png",
          chance_of_rain: 20,
          air_quality: 1
        }
      ]
    }

    weather_service = Minitest::Mock.new
    weather_service.expect :get_weather_data, mock_weather_data
    weather_service.expect :cached, false

    WeatherService.stub :new, weather_service do
      get weathers_url, params: { zip_code: "90210" }
      assert_response :success
      assert_select "h2", /Beverly Hills/
    end
  end

  test "should handle invalid location" do
    weather_service = Minitest::Mock.new
    weather_service.expect :get_weather_data, nil

    WeatherService.stub :new, weather_service do
      get weathers_url, params: { zip_code: "invalid" }
      assert_response :success
      assert_select "h1", /couldn't find weather information/
    end
  end
end
