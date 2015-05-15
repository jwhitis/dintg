class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_user_has_completed_setup!
  before_action :sanitize_currency_params, only: [:create, :update]
  before_action :combine_time_params, only: [:create, :update]
  before_action :find_event, only: [:edit, :update, :destroy]

  def index
    @events_by_date = current_user.events.grouped_by_date
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
      redirect_to calendar_events_path and return
    end

    @event = Event.new(date: params[:date])
  end

  def create
    @event = current_user.events.new(event_params)

    unless @event.valid?
      render :new and return
    end

    unless submission_confirmed? || @event.in_past?
      if current_user.is_tracking_income? && @event.is_a_gig?
        @recommendation = Recommendation.new(current_user, @event)
      end

      @conflicts = google_facade.find_conflicts(@event)

      if @recommendation || @conflicts.any?
        render :new and return
      end
    end

    if google_event = google_facade.create_event(@event.to_params)
      @event.google_id = google_event.id
      @event.save!
      flash[:notice] = "The event has been added to your Google calendar."
      redirect_to calendar_events_path
    else
      flash.now[:alert] = "Sorry, something went wrong. Please try again."
      render :new
    end
  end

  def edit
    @event.date = @event.starts_at.strftime("%Y-%-m-%-d")
  end

  def update
    @event.assign_attributes(event_params)

    unless @event.valid?
      render :edit and return
    end

    unless submission_confirmed? || @event.in_past?
      @conflicts = google_facade.find_conflicts(@event)

      if @conflicts.any?
        render :edit and return
      end
    end

    if google_facade.update_event(@event.google_id, @event.to_params)
      @event.save!
      flash[:notice] = "The event has been updated on your Google calendar."
      redirect_to events_path
    else
      flash.now[:alert] = "Sorry, something went wrong. Please try again."
      render :edit
    end
  end

  def destroy
    if google_facade.destroy_event(@event.google_id)
      @event.destroy
      flash[:notice] = "The event has been removed from your Google calendar."
      redirect_to events_path
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
    pay = params[:event][:pay]
    params[:event][:pay] = sanitize_currency(pay) if pay.present?
  end

  def combine_time_params
    params[:event][:starts_at] = "#{params[:event][:date]} #{params[:event][:starts_at]}"
    params[:event][:ends_at] = "#{params[:event][:date]} #{params[:event][:ends_at]}"
  end

  def find_event
    @event = Event.find(params[:id])
  end

  def current_time
    @current_time ||= Time.now
  end

  def submission_confirmed?
    params[:confirm_submission] == "1"
  end

  def event_params
    params.require(:event).permit(:pay, :summary, :location, :date, :starts_at, :ends_at)
  end

end
