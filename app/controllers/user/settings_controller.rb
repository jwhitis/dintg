class User::SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_user, :find_calendars

  def setup
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      redirect_to root_path, notice: "You successfully updated your settings."
    else
      render :edit
    end
  end

  private

  def find_user
    @user = current_user
  end

  def find_calendars
    calendar_facade = CalendarFacade.new(@user)
    @calendars = calendar_facade.list_calendars
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :calendar_id, :monthly_goal)
  end

end
