class WeathersController < ApplicationController

  def index
    # Use zip code entered by user or a fallback zip code
    location = params[:location] || "90210"
 
    # Get weather data from weatherapi.com via WeatherService
    weather_service = WeatherService.new(location)
    weather_data = weather_service.get_weather_data
    
    if weather_data
        @location = weather_data[:location]
        @forecast_data = weather_data[:forecast]
        @cached = weather_service.cached
    end
    
    # Update weather_data partial with new weather data
    respond_to do |format|
        format.html
        format.turbo_stream do
            render turbo_stream: turbo_stream.update("weather_data", 
                partial: "weather_data"
            )
        end
    end
  end

  private
end
