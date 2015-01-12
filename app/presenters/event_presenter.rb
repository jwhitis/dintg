class EventPresenter

  def initialize(events)
    @events = events
  end

  def event_list
    return nil if @events.empty?

    html = ""
    @events.each_with_index do |event, index|
      html += event_html(event, index + 1)
    end

    helpers.content_tag(:ol, html, { class: "event-list" }, false)
  end

  private

  def event_html(event, number)
    helpers.content_tag(:li) do
      helpers.content_tag(:div, class: "row") do
        helpers.content_tag(:div, class: "col-xs-6") do
          "#{number}. #{helpers.truncate(event.summary, length: 18)}"
        end +
        helpers.content_tag(:div, format_event_time(event), class: "col-xs-6")
      end
    end
  end

  def format_event_time(event)
    "#{event.start.date_time.strftime("%l:%M%P")} - #{event.end.date_time.strftime("%l:%M%P")}".squish
  end

  def helpers
    ActionController::Base.helpers
  end

end