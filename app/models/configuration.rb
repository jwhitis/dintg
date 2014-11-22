class Configuration < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

  belongs_to :user

  def formatted_monthly_goal
    number_to_currency(self.monthly_goal)
  end

end
