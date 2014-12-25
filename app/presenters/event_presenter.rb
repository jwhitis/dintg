class EventPresenter

  def initialize(events)
    @events = events
  end

  def event_list
    return no_events if @events.empty?
    html = @events.reduce("") { |html, event| html + event_html(event) }
    helpers.content_tag(:ul, html, { class: "event-list" }, false)
  end

  private

  def no_events
    helpers.content_tag(:p, "You're wide open that day.", class: "no-events")
  end

  def event_html(event)
    helpers.content_tag(:li, class: "event") do
      helpers.content_tag(:div, class: "row") do
        helpers.content_tag(:div, event.summary, class: "col-xs-6") +
        helpers.content_tag(:div, format_event_time(event), class: "col-xs-6")
      end
    end
  end

  def format_event_time(event)
    "#{event.start.date_time.strftime("%l:%M%P")} - #{event.end.date_time.strftime("%l:%M%P")}"
  end

  def helpers
    ActionController::Base.helpers
  end

end