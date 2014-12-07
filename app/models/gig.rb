class Gig < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

  belongs_to :user

  def to_params
    {
      "summary" => self.summary,
      "description" => "Pay: #{formatted_pay}",
      "location" => self.location,
      "start" => { "dateTime" => self.starts_at },
      "end" => { "dateTime" => self.ends_at }
    }
  end

  def formatted_pay
    number_to_currency(self.pay)
  end

  def formatted_date
    self.starts_at.strftime("%-m/%-d/%y")
  end

  def formatted_time
    "#{self.starts_at.strftime("%l:%M%P")} - #{self.ends_at.strftime("%l:%M%P")}"
  end

  def in_past?
    self.starts_at < Time.now
  end

  def self.within_time_range(time_range)
    where(starts_at: time_range)
  end

  def self.paid
    where(paid: true)
  end

end
