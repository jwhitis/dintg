class EventPresenter

  def initialize(events)
    @events = events
  end

  def event_list
    return nil if @events.empty?

    html = @events.reduce("") { |html, event| html + event_html(event) }
    helpers.content_tag(:ul, html, { class: "event-list" }, false)
  end

  private

  def event_html(event)
    helpers.content_tag(:li) do
      helpers.content_tag(:div, class: "row") do
        helpers.content_tag(:div, class: "col-xs-6") do
          helpers.content_tag(:i, "", class: "fa fa-calendar-o") + event.summary
        end +
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