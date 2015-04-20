class RecommendationPresenter
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::DateHelper

  def initialize(recommendation)
    @recommendation = recommendation
  end

  def recommendation
    if @recommendation.gig.in_past?
      html = gig_in_past
    else
      html = timeline
      html += synopsis
      html += conclusion
    end

    helpers.content_tag(:div, html, { class: "recommendation" }, false)
  end

  private

  def gig_in_past
    helpers.content_tag(:div, class: "gig-in-past info-box clearfix") do
      helpers.content_tag(:div, class: "col-left") do
        helpers.content_tag(:div, class: "circle") do
          helpers.content_tag(:span, class: "fa-stack") do
            helpers.content_tag(:i, "", class: "fa fa-calendar-o fa-stack-2x") +
            helpers.content_tag(:i, "", class: "fa fa-check fa-stack-1x")
          end
        end
      end +
      helpers.content_tag(:div, class: "col-right") do
        helpers.content_tag(:p, gig_in_past_text)
      end
    end
  end

  def gig_in_past_text
    "It looks like this gig already happened, but you can add it anyway to update your
      records.".squish.html_safe
  end

  def timeline
    html = helpers.content_tag(:h4, "Progress")
    html += marker if @recommendation.gig_period_in_progress?
    html += progress_bar
    html += helpers.content_tag(:div, formatted_earned_for_period, class: "earned-for-period")
    html += helpers.content_tag(:div, formatted_goal_for_period, class: "goal-for-period")
    helpers.content_tag(:div, html, { class: "timeline clearfix" }, false)
  end

  def marker
    helpers.content_tag(:div, class: "marker", style: "left: #{percentage_of_period_elapsed};
      left: calc(#{percentage_of_period_elapsed} - 23px);".squish) do
      helpers.content_tag(:div, "Today", class: "text") +
      helpers.content_tag(:div, "", class: "arrow") +
      helpers.content_tag(:div, "", class: "line")
    end
  end

  def percentage_of_period_elapsed
    fraction = @recommendation.calculator.fraction_of_period_elapsed
    number_to_percentage(fraction * 100, precision: 0, delimiter: ",")
  end

  def progress_bar
    helpers.content_tag(:div, class: "bar") do
      helpers.content_tag(:div, "", class: "background") +
      helpers.content_tag(:div, "", class: "foreground #{progress_bar_color}",
        style: "width: #{progress_bar_width};")
    end
  end

  def progress_bar_color
    return "green" unless @recommendation.gig_period_in_progress?
    score = @recommendation.calculator.progress_score

    if score < 0.5
      "red"
    elsif score >= 0.5 && score < 1
      "yellow"
    elsif score >= 1
      "green"
    end
  end

  def progress_bar_width
    @recommendation.calculator.fraction_of_goal_earned < 1 ? percentage_of_goal_earned : "100%"
  end

  def percentage_of_goal_earned
    fraction = @recommendation.calculator.fraction_of_goal_earned
    number_to_percentage(fraction * 100, precision: 0, delimiter: ",")
  end

  def formatted_earned_for_period
    earned = @recommendation.calculator.earned_for_period
    "Earned: #{number_to_currency(earned)}"
  end

  def formatted_goal_for_period
    goal = @recommendation.calculator.goal_for_period
    "Goal: #{number_to_currency(goal)}"
  end

  def synopsis
    text = percentage_of_goal_earned_text
    text += "&nbsp;".html_safe

    if @recommendation.gig_period_in_progress?
      text += generic_progress_text
    else
      text += period_not_in_progress_text
    end

    helpers.content_tag(:div, text, { class: "synopsis" }, false)
  end

  def percentage_of_goal_earned_text
    "So far, you've earned ".html_safe +
    helpers.content_tag(:span, percentage_of_goal_earned, class: "percentage") +
    " of your goal for " +
    helpers.content_tag(:span, formatted_time_period, class: "time-period") +
    "." +
    helpers.content_tag(:sup, "1")
  end

  def formatted_time_period
    time_period = @recommendation.time_period
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

  def generic_progress_text
    "That's #{generic_progress_descriptor} where you should be at this point.".html_safe
  end

  def generic_progress_descriptor
    score = @recommendation.calculator.progress_score

    if score < 0.9
      "behind"
    elsif score >= 0.9 && score < 1.1
      "right about"
    elsif score >= 1.1
      "ahead of"
    end
  end

  def period_not_in_progress_text
    "That's still #{distance_to_period_start} away, so don't worry if you haven't made
      much progress towards your goal.".squish.html_safe
  end

  def distance_to_period_start
    period_start = @recommendation.calculator.dictionary.time_range_for_period.first
    distance_of_time_in_words_to_now(period_start)
  end

  def conclusion
    if @recommendation.gig_period_in_progress?
      if @recommendation.gig_recommended?
        text = gig_recommended_text
      else
        text = gig_not_recommended_text
      end
    else
      text = ahead_of_schedule_text
    end

    helpers.content_tag(:div, class: "conclusion info-box clearfix") do
      helpers.content_tag(:div, class: "col-left") do
        helpers.content_tag(:div, class: "circle") do
          helpers.content_tag(:i, "", class: "fa fa-lightbulb-o")
        end
      end +
      helpers.content_tag(:div, class: "col-right") do
        helpers.content_tag(:p, text, class: text.length <= 55 ? "push" : nil)
      end
    end
  end

  def gig_recommended_text
    "You should take this gig to get on track for your goal."
  end

  def gig_not_recommended_text
    "You're on track for your goal, but you could always take this gig anyway.".html_safe
  end

  def ahead_of_schedule_text
    "Take this gig if you want to get ahead of schedule."
  end

  def helpers
    ActionController::Base.helpers
  end

end