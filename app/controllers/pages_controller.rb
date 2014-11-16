class PagesController < ApplicationController

  def index
    calendar_facade = CalendarFacade.new(current_user)
    @events = calendar_facade.find_conflicts(Gig.last)
  end

end
