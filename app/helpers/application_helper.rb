module ApplicationHelper

  def calendar_day_path(calendar, day)
    if day[1]
      new_gig_path(date: day[1])
    else
      day[0] < 7 ? next_month_path(calendar) : previous_month_path(calendar)
    end
  end

  def previous_month_path(calendar)
    year = calendar.month == 1 ? calendar.year - 1 : calendar.year
    month = calendar.month == 1 ? 12 : calendar.month - 1
    calendar_gigs_path(year: year, month: month)
  end

  def next_month_path(calendar)
    year = calendar.month == 12 ? calendar.year + 1 : calendar.year
    month = calendar.month == 12 ? 1 : calendar.month + 1
    calendar_gigs_path(year: year, month: month)
  end

  def time_options_for_select(time, offset = 0, minute_step = 15, start_hour = 0)
    options_for_select(
      time_options(minute_step, start_hour),
      selected_time(time, offset, minute_step)
    )
  end

  def time_options(minute_step, start_hour)
    unless 60 % minute_step == 0
      raise ArgumentError, "Minute step must divide evenly into 60."
    end

    options = []
    (1..24).each do |n|
      hour = n > 12 ? n - 12 : n
      ampm = n < 12 || n == 24 ? "AM" : "PM"

      counter = 0
      until counter == 60
        text = "#{hour}:#{counter.zero? ? "00" : counter} #{ampm}"
        value = "#{n == 24 ? "00" : sprintf("%02d", n)}:#{counter.zero? ? "00" : counter}"
        options << [text, value]
        counter += minute_step
      end
    end

    options.rotate(60 / minute_step * (start_hour - 1))
  end

  def selected_time(time, offset, minute_step)
    time ||= Time.now + offset.hour
    time += 1.minute until time.min % minute_step == 0
    time.strftime("%H:%M")
  end

  def format_event_time(event)
    "#{event.start.dateTime.strftime("%l:%M%P")} - #{event.end.dateTime.strftime("%l:%M%P")}"
  end

  def formatted_error_messages(resource)
    resource.errors.map do |attribute, message|
      custom_attributes = resource.try(:attributes_with_custom_error_message)

      if custom_attributes && attribute.in?(custom_attributes)
        "#{message}"
      else
        "#{attribute} #{message}.".humanize
      end
    end
  end

end
