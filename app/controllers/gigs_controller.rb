class GigsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_user_has_completed_setup
  before_action :sanitize_currency_params, only: :create

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
        flash[:notice] = "The gig has been added to your Google calendar."
      else
        flash[:alert] = "Oops, something went wrong. Please try again."
      end

      redirect_to root_path
    else
      render :new
    end
  end

  private

  def ensure_user_has_completed_setup
    unless current_user.has_completed_setup?
      flash[:notice] = "Just answer a few questions to get started."
      redirect_to setup_users_account_path
    end
  end

  def sanitize_currency_params
    if pay = params[:gig][:pay]
      params[:gig][:pay] = sanitize_currency(pay)
    end
  end

  def gig_params
    params.require(:gig).permit(:pay, :summary, :location, :starts_at, :ends_at)
  end

end
