class CalendarBuilder
  attr_reader :year, :month

  def initialize(year, month)
    @year = year
    @month = month
    @start_date = Date.new(@year, @month)
  end

  def days_in_weeks
    cells = (1..days_in_month).to_a
    day_offset.times { cells.unshift(nil) }
    cells.in_groups_of(7)
  end

  private

  def days_in_month
    @start_date.end_of_month.day
  end

  def day_offset
    Date::DAYNAMES.index(first_day_name)
  end

  def first_day_name
    @start_date.strftime("%A")
  end

end