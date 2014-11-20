class User::SettingsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user

    calendar_facade = CalendarFacade.new(@user)
    @calendars = calendar_facade.list_calendars
  end

  def update
    @user = current_user

    calendar_facade = CalendarFacade.new(@user)
    @calendars = calendar_facade.list_calendars

    if @user.update_attributes(user_params)
      flash[:notice] = "You successfully updated your settings."
    end

    render :edit
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :calendar_id)
  end

end
