class WeatherService
    attr_reader :cached

    def initialize(zip_code)
        @zip_code = zip_code
        @base_url = "https://api.weatherapi.com/v1/forecast.json?"
        @api_key = Rails.application.credentials.weather_api
        @cached = false
    end

    def get_weather_data
        cache_key = "weather_#{@zip_code}"
        
        # Check if data exists in cache before fetching
        if Rails.cache.exist?(cache_key)
            @cached = true
            return Rails.cache.read(cache_key)
        end

        # If not in cache, fetch from API and cache the result
        response = Faraday.get("#{@base_url}key=#{@api_key}&q=#{@zip_code}&days=5&aqi=yes&alerts=yes")

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
            
            result = {
                location: data['location']['name'],
                forecast: forecast_data
            }

            Rails.cache.write(cache_key, result, expires_in: 30.minutes)
            @cached = false
            result
        else
            nil
        end
    end
end