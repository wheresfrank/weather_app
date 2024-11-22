class WeatherService

    def initialize(zip_code)
        @zip_code = zip_code
        @base_url = "https://api.weatherapi.com/v1/forecast.json?"
        @api_key = Rails.application.credentials.weather_api
    end

    def get_weather_data
        response = Faraday.get("#{@base_url}key=#{@api_key}&q=#{@zip_code}&days=5&aqi=yes&alerts=yes")

        if response.status == 200
            data = JSON.parse(response.body)
            forecast_data = data['forecast']['forecastday'].map do |day|
                {
                    date: day['date'],
                    max_temp_f: day['day']['maxtemp_f'],
                    min_temp_f: day['day']['mintemp_f'],
                    max_temp_c: day['day']['maxtemp_c'],
                    min_temp_c: day['day']['mintemp_c'],
                    condition: day['day']['condition']['text'],
                    icon: day['day']['condition']['icon'],
                    chance_of_rain: day['day']['daily_chance_of_rain'],
                    humidity: day['day']['avghumidity'],
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
    end

end