class ProgressCalculator
  TIME_PERIODS = %w(month quarter half_year year)

  attr_accessor :user

  def initialize(user)
    self.user = user
  end

  def on_pace_for_period?(time_period)
    fraction_of_goal_earned_for_period(time_period) >= fraction_of_period_elapsed(time_period)
  end

  def fraction_of_period_elapsed(time_period)
    current_day_in_period(time_period).to_f / days_in_period(time_period).to_f
  end

  def fraction_of_goal_earned_for_period(time_period)
    earned_for_period(time_period).to_f / goal_for_period(time_period).to_f
  end

  private

  def current_day_in_period(time_period)
    month_range = TimeRangeDictionary.month_range_for_period(time_period)
    current_month = TimeRangeDictionary.current_month
    month_index = month_range.to_a.index(current_month)
    previous_months = month_range.to_a[0...month_index]
    days_in_range(previous_months) + Time.now.day
  end

  def days_in_period(time_period)
    month_range = TimeRangeDictionary.month_range_for_period(time_period)
    days_in_range(month_range)
  end

  def days_in_range(month_range)
    month_range.reduce(0) do |days, month|
      year = TimeRangeDictionary.current_year
      days + Time.new(year, month).end_of_month.day
    end
  end

  def earned_for_period(time_period)
    if user.configuration.exclude_unpaid?
      user.paid_gigs_for_period(time_period).sum(:pay)
    else
      user.gigs_for_period(time_period).sum(:pay)
    end
  end

  def goal_for_period(time_period)
    month_range = TimeRangeDictionary.month_range_for_period(time_period)
    monthly_goal * month_range.size
  end

  def monthly_goal
    user.configuration.monthly_goal
  end

end