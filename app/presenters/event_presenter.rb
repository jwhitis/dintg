class EventPresenter

  def initialize(events)
    @events = events
  end

  def event_list
    html = @events.reduce("") { |html, event| html + event_html(event) }
    helpers.content_tag(:ul, html, { class: "event-list" }, false)
  end

  private

  def event_html(event)
    helpers.content_tag(:li, class: "event") do
      "#{event.summary} | #{format_event_time(event)}"
    end
  end

  def format_event_time(event)
    "#{event.start.date_time.strftime("%l:%M%P")} - #{event.end.date_time.strftime("%l:%M%P")}"
  end

  def helpers
    ActionController::Base.helpers
  end

end