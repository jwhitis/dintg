class Users::AccountsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
    @calendars = find_calendars(@user)
  end

  def update
    @user = current_user
    @calendars = find_calendars(@user)

    if @user.update_attributes(user_params)
      redirect_to root_path, notice: "Your changes have been saved."
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name,
      { configuration_attributes: [:calendar_id, :monthly_goal, :exclude_unpaid] }
    )
  end

end
