class TimeRangeDictionary
  TIME_PERIODS = %w(month quarter half_year year)

  class << self

    def time_range_for_period(time_period)
      unless time_period.to_s.in?(TIME_PERIODS)
        raise ArgumentError, "\"#{time_period}\" is not a valid time period."
      end

      month_range = month_range_for_period(time_period)
      start_time = Time.new(current_year, month_range.first).beginning_of_month
      end_time = Time.new(current_year, month_range.last).end_of_month
      start_time..end_time
    end

    def month_range_for_period(time_period)
      send("month_range_for_#{time_period}")
    end

    def month_range_for_month
      current_month..current_month
    end

    def month_range_for_quarter
      if current_month <= 3
        1..3
      elsif current_month >= 4 && current_month <= 6
        4..6
      elsif current_month >= 7 && current_month <= 9
        7..9
      elsif current_month >= 10
        10..12
      end
    end

    def month_range_for_half_year
      current_month < 7 ? 1..6 : 7..12
    end

    def month_range_for_year
      1..12
    end

    def current_month
      @current_month ||= Time.now.month
    end

    def current_year
      @current_year ||= Time.now.year
    end

  end

end