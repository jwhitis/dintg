class Users::AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :sanitize_currency_params, only: :update
  before_action :find_resources

  def setup
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      redirect_to root_path, notice: success_message
    else
      if @user.has_completed_setup?
        render :edit
      else
        render :setup
      end
    end
  end

  private

  def sanitize_currency_params
    monthly_goal = params[:user][:configuration_attributes][:monthly_goal]

    if monthly_goal.present?
      params[:user][:configuration_attributes][:monthly_goal] = sanitize_currency(monthly_goal)
    end
  end

  def find_resources
    @user = current_user
    @calendars = google_facade.list_calendars
  end

  def success_message
    if @user.has_completed_setup?
      "Your changes have been saved."
    else
      "Thanks for completing your setup."
    end
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :time_zone,
      { configuration_attributes: [:calendar_id, :monthly_goal, :time_period, :id] }
    )
  end

end
