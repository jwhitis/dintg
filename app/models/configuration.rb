class Configuration < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

  belongs_to :user

  validates_inclusion_of :time_period, in: TimeRangeDictionary::TIME_PERIODS

  def formatted_monthly_goal
    number_to_currency(self.monthly_goal)
  end

end
