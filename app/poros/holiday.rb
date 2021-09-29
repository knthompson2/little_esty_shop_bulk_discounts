class Holiday
  attr_reader :name, :date
  def initialize(holiday_info)
    @name = holiday_info[:name]
    @date = holiday_info[:date]
  end
end
