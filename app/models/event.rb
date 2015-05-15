class Event < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

  attr_accessor :date

  belongs_to :user

  validates_presence_of :summary, message: "Please enter a title for this event."
  validate :ends_at_must_be_after_starts_at
  validates_numericality_of :pay, greater_than: 0, allow_nil: true,
    message: "Please enter a payment amount that is greater than $0.00."

  def attributes_with_custom_error_message
    [:summary, :ends_at, :pay]
  end

  def is_a_gig?
    !!self.pay
  end

  def to_params
    params = {
      "summary" => self.summary,
      "location" => self.location,
      "start" => { "dateTime" => self.starts_at.iso8601 },
      "end" => { "dateTime" => self.ends_at.iso8601 }
    }

    is_a_gig? ? params.merge(gig_params) : params
  end

  def gig_params
    { "description" => "Pay: #{number_to_currency(self.pay)}" }
  end

  def in_past?
    self.starts_at && self.starts_at < Time.now
  end

  def self.within_time_range(time_range)
    where(starts_at: time_range)
  end

  def self.grouped_by_date
    events_hash = select("*, DATE(starts_at) starts_on").order(:starts_at).group_by(&:starts_on)
    events_hash.to_a.reverse.to_h
  end

  private

  def ends_at_must_be_after_starts_at
    if self.ends_at <= self.starts_at
      errors.add(:ends_at, "Please choose an end time that is after the start time.")
    end
  end 

end
