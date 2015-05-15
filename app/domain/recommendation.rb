class Recommendation
  attr_reader :user, :time_period, :gig, :calculator

  def initialize(user, gig)
    unless user.is_tracking_income?
      raise ArgumentError, "User must have monthly goal for recommendation to be made."
    end

    @user = user
    @time_period = @user.configuration.time_period
    @gig = gig
    @calculator = ProgressCalculator.new(@user, @time_period, @gig.starts_at)
  end

  def gig_period_in_progress?
    @calculator.dictionary.period_in_progress?
  end

  def gig_recommended?
    !@calculator.on_pace_for_period?
  end

end