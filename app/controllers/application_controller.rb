class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  around_filter :set_time_zone

  # Use the time zone preference of the current user for this request.
  def set_time_zone(&block)
    time_zone = current_user.try(:time_zone) || "UTC"
    Time.use_zone(time_zone, &block)
  end

  # Since we aren't using :database_authenticatable, we have to define the following
  # helper method so it can correctly redirect in case of failure.
  # https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview#using-omniauth-without-other-authentications
  def new_session_path(scope)
    new_user_session_path
  end

  def sanitize_currency(value)
    value.tr("$,", "")
  end

  def google_facade
    @google_facade ||= GoogleAPIFacade.new(current_user)
  end

end
