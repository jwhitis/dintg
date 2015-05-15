class CalendarBuilder
  include Rails.application.routes.url_helpers

  DENSITY_MAX = 5

  attr_reader :year, :month

  def initialize(year, month, user)
    @year = year.to_i
    @month = month.to_i
    @start_date = Date.new(@year, @month)
    @user = user
  end

  def days_in_weeks
    days = (1..days_in_month).map do |day|
      events = events_for_day(day)
      event_presenter = GoogleEventPresenter.new(events)
      [day, day_path(day), event_density(events), event_presenter.event_list, day_title(day)]
    end

    day_offset.times { |n| days.unshift([days_in_previous_month - n]) }

    counter = 0
    days << [counter += 1] until days.size >= 35 && days.size % 7 == 0

    days.in_groups_of(7, false)
  end

  def heading
    "#{Date::MONTHNAMES[@month]} #{@year}"
  end

  private

  def days_in_month
    @start_date.end_of_month.day
  end

  def events_for_day(day)
    day_date = Date.new(@year, @month, day)

    google_events.select do |event|
      event_dates = event_dates(event)
      event_dates.detect { |event_date| event_date == day_date }
    end
  end

  def google_events
    @google_events ||= google_facade.list_events_for_month(@year, @month)

    @sorted_events ||= @google_events.sort_by do |event|
      event.start.date_time || event.start.date.to_time
    end
  end

  def google_facade
    @google_facade ||= GoogleAPIFacade.new(@user)
  end

  def event_dates(event)
    start_date = (event.start.date_time || event.start.date).to_date
    end_date = (event.end.date_time || event.end.date).to_date

    # For all day events, which end at midnight on the next day.
    end_date -= 1.day if event.start.date && event.end.date

    (start_date..end_date).to_a
  end

  def day_path(day)
    date = date_string(day)
    new_event_path(date: date)
  end

  def date_string(day)
    "#{@year}-#{@month}-#{day}"
  end

  def event_density(events)
    # Density values range from 0.0 to 1.0. A score above 0.0 indicates that at
    # least one event is scheduled for that day. If the number of events exceeds
    # DENSITY_MAX, 1.0 will be returned.
    density = events.size.to_f / DENSITY_MAX.to_f
    density > 1 ? 1 : density
  end

  def day_title(day)
    date = Date.new(@year, @month, day)
    date.strftime("%A, %B #{day.ordinalize}")
  end

  def day_offset
    Date::DAYNAMES.index(first_day_name)
  end

  def first_day_name
    @start_date.strftime("%A")
  end

  def days_in_previous_month
    date = @month == 1 ? Date.new(@year - 1, 12) : Date.new(@year, @month - 1)
    date.end_of_month.day
  end

end