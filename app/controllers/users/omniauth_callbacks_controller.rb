class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def google_oauth2
    @user = User.find_for_google_oauth2(omniauth_data)

    if @user.persisted?
      @user.token.fresh_token
      flash[:notice] = I18n.t("devise.omniauth_callbacks.success", kind: "Google")
      sign_in_and_redirect @user, event: :authentication
    else
      flash[:notice] = "Sorry, something went wrong. Please try again."
      redirect_to new_user_session_path
    end
  end

  private

  def omniauth_data
    request.env["omniauth.auth"]
  end

end
