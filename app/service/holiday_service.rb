class HolidayService
  def holiday
    get_url("https://date.nager.at/api/v3/NextPublicHolidays/US")
  end

  def get_url(url)
    response = Faraday.get(url)
    JSON.parse(response.body, symbolize_names: true)
  end
end
