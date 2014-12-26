class GigsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_user_has_completed_setup
  before_action :sanitize_currency_params, only: [:create, :update]
  before_action :combine_time_params, only: [:create, :update]

  def index
    @gigs = current_user.gigs
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

    if @gig.valid?
      google_facade = GoogleAPIFacade.new(current_user)

      unless params[:double_confirmation] == "true"
        @recommendation = Recommendation.new(current_user, @gig)
        @conflicts = google_facade.find_conflicts(@gig)
        render :new and return
      end

      event = google_facade.create_event(@gig.to_params)

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
    @gig.date = @gig.starts_at.strftime("%Y-%-m-%-d")
  end

  def update
    @gig = Gig.find(params[:id])
    @gig.assign_attributes(gig_params)

    if @gig.valid?
      google_facade = GoogleAPIFacade.new(current_user)

      unless params[:double_confirmation] == "true"
        @conflicts = google_facade.find_conflicts(@gig)

        if @conflicts.any?
          render :edit and return
        end
      end

      event = google_facade.update_event(@gig.google_id, @gig.to_params)

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

    google_facade = GoogleAPIFacade.new(current_user)

    if google_facade.destroy_event(@gig.google_id)
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

  def combine_time_params
    params[:gig][:starts_at] = "#{params[:gig][:date]} #{params[:gig][:starts_at]}"
    params[:gig][:ends_at] = "#{params[:gig][:date]} #{params[:gig][:ends_at]}"
  end

  def current_time
    @current_time ||= Time.now
  end

  def gig_params
    params.require(:gig).permit(:pay, :summary, :location, :date, :starts_at, :ends_at)
  end

end
