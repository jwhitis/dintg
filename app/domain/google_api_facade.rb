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
    month_time = Time.new(year, month)
    list_events(month_time.beginning_of_month, month_time.end_of_month)
  end

  def find_conflicts(gig)
    events = list_events(gig.starts_at, gig.ends_at)
    events.delete_if { |event| event.id == gig.google_id }
  end

  def list_events(start_time, end_time)
    result = @client.execute(
      api_method: calendar_api.events.list,
      parameters: {
        "calendarId" => @user.configuration.calendar_id,
        "timeMin" => start_time.iso8601,
        "timeMax" => end_time.iso8601
      }
    )

    result.data.items
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