class CalendarFacade

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

  def create_event(event_params)
    result = @client.execute(
      api_method: calendar_api.events.insert,
      parameters: { "calendarId" => @user.configuration.calendar_id },
      body: event_params.to_json,
      headers: { "Content-Type" => "application/json" }
    )

    result.status == 200
  end

  def find_conflicts(gig)
    result = @client.execute(
      api_method: calendar_api.events.list,
      parameters: {
        "calendarId" => @user.configuration.calendar_id,
        "timeMin" => gig.starts_at.iso8601,
        "timeMax" => gig.ends_at.iso8601
      }
    )

    result.data.items
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