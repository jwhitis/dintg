class Users::ConfigurationsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @configuration = current_user.configuration
    @calendars = find_calendars(current_user)
  end

  def update
    @configuration = current_user.configuration
    @calendars = find_calendars(current_user)

    if @configuration.update_attributes(configuration_params)
      redirect_to root_path, notice: "Thanks for completing your setup."
    else
      render :edit
    end
  end

  private

  def configuration_params
    params.require(:configuration).permit(:calendar_id, :monthly_goal, :exclude_unpaid)
  end

end
