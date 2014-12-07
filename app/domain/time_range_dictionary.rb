class TimeRangeDictionary
  TIME_PERIODS = %w(month quarter half_year year)

  def initialize(time_period = "month", target = Time.now)
    unless time_period.to_s.in?(TIME_PERIODS)
      raise TimePeriodError, "\"#{time_period}\" is not a valid time period."
    end

    @time_period = time_period
    @target_month = target.month
    @target_year = target.year
  end

  class TimePeriodError < ArgumentError; end

  def period_in_progress?
    time_range_for_period.cover?(Time.now)
  end

  def time_range_for_period
    start_time = Time.new(@target_year, month_range_for_period.first).beginning_of_month
    end_time = Time.new(@target_year, month_range_for_period.last).end_of_month
    start_time..end_time
  end

  def month_range_for_period
    @month_range ||= send("month_range_for_#{@time_period}")
  end

  private

  def month_range_for_month
    @target_month..@target_month
  end

  def month_range_for_quarter
    if @target_month <= 3
      1..3
    elsif @target_month >= 4 && @target_month <= 6
      4..6
    elsif @target_month >= 7 && @target_month <= 9
      7..9
    elsif @target_month >= 10
      10..12
    end
  end

  def month_range_for_half_year
    @target_month < 7 ? 1..6 : 7..12
  end

  def month_range_for_year
    1..12
  end

end