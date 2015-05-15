class GoogleAPIFacade

  def initialize(user)
    @user = user
    @client = client
    @client.authorization.access_token = @user.token.fresh_token
  end

  def list_calendars
    result = @client.execute(
      api_method: calendar_api.calendar_list.list
    )

    result.data.items
  end

  def list_events_for_month(year, month)
    min_end_time = Time.new(year, integer_to_month(month - 1)).end_of_month
    max_start_time = Time.new(year, integer_to_month(month + 1)).beginning_of_month
    list_events(min_end_time, max_start_time)
  end

  def integer_to_month(integer)
    month = integer % 12
    month == 0 ? 12 : month
  end

  def find_conflicts(event)
    google_events = list_events(event.starts_at, event.ends_at)
    google_events.delete_if { |google_event| google_event.id == event.google_id }
  end

  def list_events(min_end_time, max_start_time)
    result = @client.execute(
      api_method: calendar_api.events.list,
      parameters: {
        "calendarId" => @user.configuration.calendar_id,
        # The documentation says that timeMin is inclusive and timeMax
        # is exclusive, but I found them both to be exclusive.
        # https://developers.google.com/google-apps/calendar/v3/reference/events/list
        "timeMin" => min_end_time.iso8601,
        "timeMax" => max_start_time.iso8601,
        "timeZone" => formatted_time_zone
      }
    )

    result.data.items
  end

  def formatted_time_zone
    ActiveSupport::TimeZone::MAPPING.fetch(@user.time_zone)
  end

  def create_event(event_params)
    result = @client.execute(
      api_method: calendar_api.events.insert,
      parameters: { "calendarId" => @user.configuration.calendar_id },
      body: event_params.to_json,
      headers: { "Content-Type" => "application/json" }
    )

    result.data.status == "confirmed" ? result.data : false
  end

  def update_event(event_id, event_params)
    result = @client.execute(
      api_method: calendar_api.events.patch,
      parameters: {
        "calendarId" => @user.configuration.calendar_id,
        "eventId" => event_id
      },
      body: event_params.to_json,
      headers: { "Content-Type" => "application/json" }
    )

    # Recreate the event if it no longer exists.
    if result.data.status == "cancelled"
      return create_event(event_params)
    end

    result.data.status == "confirmed" ? result.data : false
  end

  def destroy_event(event_id)
    result = @client.execute(
      api_method: calendar_api.events.delete,
      parameters: {
        "calendarId" => @user.configuration.calendar_id,
        "eventId" => event_id
      }
    )

    # The event was successfully deleted or it no longer exists.
    result.response.status == 204 || result.response.status == 410
  end

  private

  def calendar_api
    @calendar_api ||= @client.discovered_api("calendar", "v3")
  end

  def client
    Google::APIClient.new(
      application_name: "Do I Need This Gig?",
      application_version: "v1"
    )
  end

end