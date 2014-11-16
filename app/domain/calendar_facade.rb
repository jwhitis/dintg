class CalendarFacade
  attr_accessor :user, :client

  def initialize(user)
    self.user = user
    self.client = new_client
    client.authorization.access_token = user.access_token
  end

  def create_event(event_params)
    result = client.execute(
      api_method: calendar.events.insert,
      parameters: { "calendarId" => user.email },
      body: event_params.to_json,
      headers: { "Content-Type" => "application/json" }
    )

    result.status == 200
  end

  def find_conflicts(gig)
    result = client.execute(
      api_method: calendar.events.list,
      parameters: {
        "calendarId" => user.email,
        "timeMin" => gig.starts_at.iso8601,
        "timeMax" => gig.ends_at.iso8601
      }
    )

    result.data.items
  end

  private

  def new_client
    Google::APIClient.new(
      application_name: "Do I Need This Gig?",
      application_version: "v1"
    )
  end

  def calendar
    client.discovered_api("calendar", "v3")
  end

end