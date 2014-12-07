class ProgressCalculator
  attr_reader :dictionary

  def initialize(user, time_period, target)
    @user = user
    @dictionary = TimeRangeDictionary.new(time_period, target)
  end

  def on_pace_for_period?
    progress_score >= 1
  end

  def progress_score
    unless @dictionary.period_in_progress?
      raise OutOfRangeError, "Cannot calculate progress score because time period is not in progress."
    end

    # A score of 1.0 indicates that a user is exactly on pace to meet their
    # goal for the time period. A score greater than 1.0 indicates that the
    # user is ahead of schedule to meet their goal.
    @score ||= fraction_of_goal_earned / fraction_of_period_elapsed
  end

  class OutOfRangeError < RuntimeError; end

  def fraction_of_goal_earned
    earned_for_period.to_f / goal_for_period.to_f
  end

  private

  def earned_for_period
    time_range = @dictionary.time_range_for_period

    if @user.configuration.exclude_unpaid?
      @user.gigs.paid.within_time_range(time_range).sum(:pay)
    else
      @user.gigs.within_time_range(time_range).sum(:pay)
    end
  end

  def goal_for_period
    monthly_goal = @user.configuration.monthly_goal
    number_of_months = @dictionary.month_range_for_period.size
    monthly_goal * number_of_months
  end

  def fraction_of_period_elapsed
    current_day_in_period.to_f / days_in_period.to_f
  end

  def current_day_in_period
    month_range = @dictionary.month_range_for_period
    previous_months = month_range.take_while { |month| month != Time.now.month }
    days_in_month_range(previous_months) + Time.now.day
  end

  def days_in_period
    month_range = @dictionary.month_range_for_period
    days_in_month_range(month_range)
  end

  def days_in_month_range(month_range)
    month_range.reduce(0) do |days, month|
      year = Time.now.year
      days + Time.new(year, month).end_of_month.day
    end
  end

end