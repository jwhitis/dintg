class Users::AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_resources
  before_action :sanitize_currency_params, only: :update

  def setup
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      redirect_to root_path, notice: success_message
    else
      render :edit
    end
  end

  private

  def load_resources
    @user = current_user
    @configuration = @user.configuration
    @calendars = find_calendars(@user)
  end

  def find_calendars(user)
    calendar_facade = CalendarFacade.new(user)
    calendar_facade.list_calendars
  end

  def sanitize_currency_params
    if monthly_goal = params[:user][:configuration_attributes][:monthly_goal]
      params[:user][:configuration_attributes][:monthly_goal] = sanitize_currency(monthly_goal)
    end
  end

  def success_message
    if request.referer.end_with?("setup")
      "Thanks for completing your setup."
    elsif request.referer.end_with("edit")
      "Your changes have been saved."
    end
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name,
      { configuration_attributes: [:calendar_id, :monthly_goal, :exclude_unpaid] }
    )
  end

end
