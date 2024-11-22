class WeatherService
    attr_reader :cached, :location

    def initialize(location)
        @location = location
        @base_url = "https://api.weatherapi.com/v1/forecast.json?"
        @api_key = Rails.application.credentials.weather_api
        @cached = false
    end

    def get_weather_data
        cache_key = "weather_#{@location}"
        
        # Check if it exists in cache before fetching
        @cached = Rails.cache.exist?(cache_key)
        
        # Use fetch to either return cached value or get new data
        Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
            @cached = false
            fetch_from_api
        end
    end

    private

    def fetch_from_api
        response = Faraday.get("#{@base_url}key=#{@api_key}&q=#{@location}&days=5&aqi=yes&alerts=yes")

        if response.status == 200
            data = JSON.parse(response.body)
            forecast_data = data['forecast']['forecastday'].map do |day|
                {
                    date: day['date'],
                    max_temp_f: day['day']['maxtemp_f'],
                    min_temp_f: day['day']['mintemp_f'],
                    condition: day['day']['condition']['text'],
                    icon: day['day']['condition']['icon'],
                    chance_of_rain: day['day']['daily_chance_of_rain'],
                    air_quality: day['day']['air_quality']['us-epa-index']
                }
            end
            
            {
                location: data['location']['name'],
                forecast: forecast_data
            }
        else
            nil
        end
    rescue JSON::ParserError, Faraday::Error => e
        Rails.logger.error("Weather API error: #{e.message}")
        nil
    end
end