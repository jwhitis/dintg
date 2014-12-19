class CalendarBuilder
  attr_reader :year, :month

  def initialize(year, month)
    @year = year.to_i
    @month = month.to_i
    @start_date = Date.new(@year, @month)
  end

  def days_in_weeks
    days = (1..days_in_month).map { |day| [day, date_string(day)] }
    day_offset.times { |n| days.unshift([days_in_previous_month - n, nil]) }

    counter = 0
    days << [counter += 1, nil] until days.size % 7 == 0

    days.in_groups_of(7, false)
  end

  private

  def days_in_month
    @start_date.end_of_month.day
  end

  def days_in_previous_month
    date = @month == 1 ? Date.new(@year - 1, 12) : Date.new(@year, @month - 1)
    date.end_of_month.day
  end

  def date_string(day)
    "#{@year}-#{@month}-#{day}"
  end

  def day_offset
    Date::DAYNAMES.index(first_day_name)
  end

  def first_day_name
    @start_date.strftime("%A")
  end

end