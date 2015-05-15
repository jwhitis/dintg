class GoogleEventPresenter

  def initialize(events)
    @events = events
  end

  def event_list
    return nil if @events.empty?

    html = ""
    @events.each_with_index do |event, index|
      html += event_html(event, index + 1)
    end

    helpers.content_tag(:div, html, { class: "google-event-list" }, false)
  end

  private

  def event_html(event, number)
    helpers.content_tag(:div, class: "row") do
      helpers.content_tag(:div, class: "col-xs-6") do
        "#{number}. #{helpers.truncate(event.summary, length: 18)}"
      end +
      helpers.content_tag(:div, format_event_time(event), class: "col-xs-6")
    end
  end

  def format_event_time(event)
    if event.start.date && event.end.date
      return helpers.content_tag(:span, "ALL DAY", class: "all-day")
    end

    event_start = event.start.date_time
    event_end = event.end.date_time

    start_time = event_start.strftime("%l:%M%P")
    end_time = event_end.strftime("%l:%M%P")

    multi_day_event = event_start.to_date != event_end.to_date
    start_date = multi_day_event ? event_start.strftime("(%-m/%-d)") : nil
    end_date = multi_day_event ? event_end.strftime("(%-m/%-d)") : nil

    "#{start_time} #{start_date} - #{end_time} #{end_date}".squish
  end

  def helpers
    ActionController::Base.helpers
  end

end