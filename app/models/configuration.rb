class Configuration < ActiveRecord::Base
  belongs_to :user

  validates_numericality_of :monthly_goal, greater_than: 0, allow_nil: true,
    message: "Please enter a monthly goal that is greater than $0.00."
  validates_inclusion_of :time_period, in: TimeRangeDictionary::TIME_PERIODS
end
