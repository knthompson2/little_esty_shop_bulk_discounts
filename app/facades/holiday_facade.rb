class HolidayFacade
  def self.holidays
    holiday_info = HolidayService.new.holiday
    holidays = holiday_info.map do |info|
      Holiday.new(info)
    end
    holidays.first(3)
  end
end
