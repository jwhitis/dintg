module ApplicationHelper

  def format_event_time(event)
    "#{event.start.dateTime.strftime("%l:%M%P")} - #{event.end.dateTime.strftime("%l:%M%P")}"
  end

end
