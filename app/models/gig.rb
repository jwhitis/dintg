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

end
