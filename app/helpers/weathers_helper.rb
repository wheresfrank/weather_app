module WeathersHelper

    # Display the date in Day, month day. Example: "Friday, Nov 22"
    def forecast_date(date)
        date = Date.parse(date)
        date.strftime("%A, %b %d")
    end

    # Rounds to a whole number and adds fahrenheit
    def forcast_temp(temp)
        "#{temp.round}°F"
    end

    # Translates air_quality to descriptive text. Source: [https://www.weatherapi.com/docs/#intro-aqi]
    def air_quality(aqi)
        case aqi
        when 1
            "Good"
        when 2
            "Moderate"
        when 3
            "Unhealthy for sensitive groups"
        when 4
            "Unhealthy"
        when 5
            "Very Unhealthy"
        when 6
            "Hazardous"
        else
            "Unknown"
        end
    end
end
