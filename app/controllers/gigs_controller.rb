class GigsController < ApplicationController
  before_action :authenticate_user!

  def new
    @gig = Gig.new
  end

  def create
    @gig = current_user.gigs.new(gig_params)

    if @gig.valid?
      calendar_facade = CalendarFacade.new(current_user)

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

  def gig_params
    params.require(:gig).permit(:pay, :summary, :location, :starts_at, :ends_at)
  end

end
