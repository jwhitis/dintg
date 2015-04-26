class GigsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_user_has_completed_setup!
  before_action :sanitize_currency_params, only: [:create, :update]
  before_action :combine_time_params, only: [:create, :update]
  before_action :find_gig, only: [:edit, :update, :destroy]

  def index
    @gigs_by_date = current_user.gigs.grouped_by_date
  end

  def calendar
    @calendar = CalendarBuilder.new(
      params[:year] || current_time.year,
      params[:month] || current_time.month,
      current_user
    )
  end

  def new
    unless params[:date]
      redirect_to calendar_gigs_path and return
    end

    @gig = Gig.new(date: params[:date])
  end

  def create
    @gig = current_user.gigs.new(gig_params)

    unless @gig.valid?
      render :new and return
    end

    unless submission_confirmed?
      @recommendation = Recommendation.new(current_user, @gig)
      @conflicts = google_facade.find_conflicts(@gig) unless @gig.in_past?
      render :new and return
    end

    if event = google_facade.create_event(@gig.to_params)
      @gig.google_id = event.id
      @gig.save!
      flash[:notice] = "The gig has been added to your Google calendar."
      redirect_to calendar_gigs_path
    else
      flash.now[:alert] = "Sorry, something went wrong. Please try again."
      render :new
    end
  end

  def edit
    @gig.date = @gig.starts_at.strftime("%Y-%-m-%-d")
  end

  def update
    @gig.assign_attributes(gig_params)

    unless @gig.valid?
      render :edit and return
    end

    unless submission_confirmed? || @gig.in_past?
      @conflicts = google_facade.find_conflicts(@gig)

      if @conflicts.any?
        render :edit and return
      end
    end

    if google_facade.update_event(@gig.google_id, @gig.to_params)
      @gig.save!
      flash[:notice] = "The gig has been updated on your Google calendar."
      redirect_to gigs_path
    else
      flash.now[:alert] = "Sorry, something went wrong. Please try again."
      render :edit
    end
  end

  def destroy
    if google_facade.destroy_event(@gig.google_id)
      @gig.destroy
      flash[:notice] = "The gig has been removed from your Google calendar."
      redirect_to gigs_path
    else
      flash.now[:alert] = "Sorry, something went wrong. Please try again."
      render :edit
    end
  end

  private

  def ensure_user_has_completed_setup!
    unless current_user.has_completed_setup?
      flash[:notice] = "Just answer a few questions to get started."
      redirect_to setup_users_account_path
    end
  end

  def sanitize_currency_params
    pay = params[:gig][:pay]
    params[:gig][:pay] = sanitize_currency(pay) if pay.present?
  end

  def combine_time_params
    params[:gig][:starts_at] = "#{params[:gig][:date]} #{params[:gig][:starts_at]}"
    params[:gig][:ends_at] = "#{params[:gig][:date]} #{params[:gig][:ends_at]}"
  end

  def find_gig
    @gig = Gig.find(params[:id])
  end

  def current_time
    @current_time ||= Time.now
  end

  def submission_confirmed?
    params[:confirm_submission] == "1"
  end

  def google_facade
    @google_facade ||= GoogleAPIFacade.new(current_user)
  end

  def gig_params
    params.require(:gig).permit(:pay, :summary, :location, :date, :starts_at, :ends_at)
  end

end
