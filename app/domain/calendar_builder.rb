class CalendarBuilder
  DENSITY_MAX = 5

  attr_reader :year, :month

  def initialize(year, month, user)
    @year = year.to_i
    @month = month.to_i
    @start_date = Date.new(@year, @month)

    google_facade = GoogleAPIFacade.new(user)
    @events = google_facade.list_events_for_month(@year, @month)
  end

  def days_in_weeks
    days = (1..days_in_month).map { |day| [day, date_string(day), event_density(day)] }
    day_offset.times { |n| days.unshift([days_in_previous_month - n, nil]) }

    counter = 0
    days << [counter += 1, nil] until days.size % 7 == 0

    days.in_groups_of(7, false)
  end

  def heading
    "#{Date::MONTHNAMES[@month]} #{@year}"
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

  def event_density(day)
    day_time = Time.new(@year, @month, day)
    day_time_range = (day_time.beginning_of_day..day_time.end_of_day)

    events_for_day = @events.select do |event|
      event_time = event.start.date_time
      day_time_range.cover?(event_time)
    end

    # Density values range from 0.0 to 1.0. A score above 0.0 indicates that at
    # least one event is scheduled for that day. If the number of events exceeds
    # DENSITY_MAX, 1.0 will be returned.
    density = events_for_day.size.to_f / DENSITY_MAX.to_f
    density > 1 ? 1 : density
  end

  def day_offset
    Date::DAYNAMES.index(first_day_name)
  end

  def first_day_name
    @start_date.strftime("%A")
  end

end