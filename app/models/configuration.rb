class Configuration < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

  belongs_to :user

  validates_numericality_of :monthly_goal, greater_than: 0, less_than: 1000000,
    message: "Please enter a monthly goal that is more than $0.00 and less than $1,000,000.00.",
    on: :update
  validates_inclusion_of :time_period, in: TimeRangeDictionary::TIME_PERIODS

  def formatted_monthly_goal(unit = "$")
    number_to_currency(self.monthly_goal, unit: unit)
  end

end
