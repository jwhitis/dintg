class GigsController < ApplicationController
  include ActionView::Helpers::NumberHelper
  before_action :authenticate_user!

  def create
    @gig = Gig.create(gig_params)

    client = Google::APIClient.new(
      application_name: "Do I Need This Gig?",
      application_version: "v1"
    )
    client.authorization.access_token = current_user.token.access_token
    calendar = client.discovered_api("calendar", "v3")
    event_body = {
      "summary" => @gig.summary,
      "description" => "Pays: #{number_to_currency(@gig.pay)}",
      "location" => @gig.location,
      "start" => { "dateTime" => @gig.starts_at },
      "end" => { "dateTime" => @gig.ends_at }
    }.to_json

    client.execute(
      api_method: calendar.events.insert,
      parameters: { "calendarId" => current_user.email },
      body: event_body,
      headers: { "Content-Type" => "application/json" }
    )

    redirect_to root_path, notice: "You successfully created a calendar event."
  end

  def gig_params
    params.require(:gig).permit(:pay, :summary, :location, :starts_at, :ends_at)
  end

end
