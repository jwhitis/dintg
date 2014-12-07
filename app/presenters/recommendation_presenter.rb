class RecommendationPresenter
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::DateHelper

  def initialize(recommendation)
    @recommendation = recommendation
  end

  def recommendation_html
    if @recommendation.gig.in_past?
      html = gig_in_past_statement
    else
      html = percentage_of_goal_earned_statement

      if @recommendation.gig_period_in_progress?
        html += generic_progress_statement
      else
        html += period_not_in_progress_statement
      end

      if @recommendation.gig_period_in_progress? && @recommendation.gig_recommended?
        html += gig_recommended_statement
      else
        html += gig_not_recommended_statement
      end
    end

    helpers.content_tag(:div, html, { class: "recommendation" }, false)
  end

  private

  def gig_in_past_statement
    helpers.content_tag(:p) do
      "It looks like this gig has already happened. Feel free to add it anyway
      if you'd like to update your records.".squish.html_safe
    end
  end

  def percentage_of_goal_earned_statement
    helpers.content_tag(:p) do
      "This gig will take place in #{formatted_time_period}. So far, you've earned
      #{percentage_of_goal_earned} of your goal for that #{time_period_name}.".squish.html_safe
    end
  end

  def formatted_time_period
    time_period = @recommendation.user.configuration.time_period
    send("formatted_#{time_period}")
  end

  def formatted_month
    start_time.strftime("%B of %Y")
  end

  def formatted_quarter
    "the #{ordinalized_quarter} quarter of #{formatted_year}"
  end

  def ordinalized_quarter
    month = start_time.month

    if month <= 3
      "first"
    elsif month >= 4 && month <= 6
      "second"
    elsif month >= 7 && month <= 9
      "third"
    elsif month >= 10
      "fourth"
    end
  end

  def formatted_half_year
    "the #{start_time.month < 7 ? "first" : "second"} half of #{formatted_year}"
  end

  def formatted_year
    start_time.strftime("%Y")
  end

  def start_time
    @recommendation.gig.starts_at
  end

  def percentage_of_goal_earned
    fraction = @recommendation.calculator.fraction_of_goal_earned
    number_to_percentage(fraction * 100, precision: 0, delimiter: ",")
  end

  def time_period_name
    @recommendation.time_period.gsub("_", " ")
  end

  def generic_progress_statement
    helpers.content_tag(:p) do
      "That's #{generic_progress_description} where you should be at this point
      in the #{time_period_name}.".squish.html_safe
    end
  end

  def generic_progress_description
    score = @recommendation.calculator.progress_score

    if score < 0.9
      "behind"
    elsif score >= 0.9 && score < 1.1
      "right about"
    elsif score >= 1.1
      "ahead of"
    end
  end

  def period_not_in_progress_statement
    helpers.content_tag(:p) do
      "The #{time_period_name} in which this gig will take place is still
      #{distance_to_period_start} away, so don't worry if you haven't made
      much progress towards your goal.".squish.html_safe
    end
  end

  def distance_to_period_start
    period_start = @recommendation.calculator.dictionary.time_range_for_period.first
    distance_of_time_in_words_to_now(period_start)
  end

  def gig_recommended_statement
    helpers.content_tag(:p) do
      "You should take this gig to stay on track for your goal."
    end
  end

  def gig_not_recommended_statement
    helpers.content_tag(:p) do
      "You don't need this gig to stay on track for your goal, but it wouldn't
      hurt to take it anyway.".squish.html_safe
    end
  end

  def helpers
    ActionController::Base.helpers
  end

end