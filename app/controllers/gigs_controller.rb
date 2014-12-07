class GigsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_user_has_completed_setup
  before_action :sanitize_currency_params, only: [:create, :update]

  def index
    @gigs = current_user.gigs
  end

  def new
    @gig = Gig.new
  end

  def create
    @gig = current_user.gigs.new(gig_params)

    if @gig.valid?
      calendar_facade = CalendarFacade.new(current_user)

      unless params[:double_confirmation] == "true"
        @recommendation = Recommendation.new(current_user, @gig)
        @conflicts = calendar_facade.find_conflicts(@gig)
        render :new and return
      end

      event = calendar_facade.create_event(@gig.to_params)

      if event.status == "confirmed"
        @gig.google_id = event.id
        @gig.save
        flash[:notice] = "The gig has been added to your Google calendar."
        redirect_to root_path
      else
        flash[:alert] = "Sorry, something went wrong. Please try again."
        render :new
      end
    else
      render :new
    end
  end

  def edit
    @gig = Gig.find(params[:id])
  end

  def update
    @gig = Gig.find(params[:id])
    @gig.assign_attributes(gig_params)

    if @gig.valid?
      calendar_facade = CalendarFacade.new(current_user)

      unless params[:double_confirmation] == "true"
        @conflicts = calendar_facade.find_conflicts(@gig)

        if @conflicts.any?
          render :edit and return
        end
      end

      event = calendar_facade.update_event(@gig.google_id, @gig.to_params)

      if event.status == "confirmed"
        @gig.update_attributes(gig_params)
        flash[:notice] = "The gig has been updated on your Google calendar."
        redirect_to root_path
      else
        flash[:alert] = "Sorry, something went wrong. Please try again."
        render :edit
      end
    else
      render :edit
    end
  end

  def destroy
    @gig = Gig.find(params[:id])

    calendar_facade = CalendarFacade.new(current_user)

    if calendar_facade.destroy_event(@gig.google_id)
      @gig.destroy
      flash[:notice] = "The gig has been removed from your Google calendar."
      redirect_to root_path
    else
      flash[:alert] = "Sorry, something went wrong. Please try again."
      redirect_to gigs_path
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
