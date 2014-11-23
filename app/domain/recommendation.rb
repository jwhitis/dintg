class Recommendation
  include ActionView::Helpers::NumberHelper

  attr_accessor :user, :gig, :calculator

  def initialize(user, gig)
    self.user = user
    self.gig = gig
    self.calculator = ProgressCalculator.new(user)
  end

  def recommend_gig?
    !calculator.on_pace_for_period?(time_period_for_gig)
  end

  def progress_score_as_percentage
    score = calculator.normalized_progress_score(time_period_for_gig)
    number_to_percentage(score * 100, precision: 0, delimiter: ",")
  end

  def time_period_for_gig
    TimeRangeDictionary::TIME_PERIODS.find do |time_period|
      time_range = TimeRangeDictionary.time_range_for_period(time_period)
      time_range.cover?(start_time)
    end
  end

  private

  def start_time
    start_time = gig.starts_at
  end

end