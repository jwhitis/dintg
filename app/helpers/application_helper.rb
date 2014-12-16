module ApplicationHelper

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
