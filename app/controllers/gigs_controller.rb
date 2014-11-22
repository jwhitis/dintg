class GigsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_user_has_completed_setup

  def new
    @gig = Gig.new
  end

  def create
    @gig = current_user.gigs.new(gig_params)

    if @gig.valid?
      calendar_facade = CalendarFacade.new(current_user)

      unless params[:ignore_conflicts] == "true"
        @conflicts = calendar_facade.find_conflicts(@gig)

        if @conflicts.any?
          render :new and return
        end
      end

      if calendar_facade.create_event(@gig.to_params)
        @gig.save
        flash[:notice] = "You successfully added a gig to your calendar."
      else
        flash[:notice] = "Sorry, something went wrong. Please try again."
      end

      redirect_to root_path
    else
      render :new
    end
  end

  private

  def ensure_user_has_completed_setup
    unless current_user.has_completed_setup?
      redirect_to edit_users_configuration_path
    end
  end

  def gig_params
    params.require(:gig).permit(:pay, :summary, :location, :starts_at, :ends_at)
  end

end
