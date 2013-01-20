class WelcomeController < ApplicationController

    def index
        @chart_data = EventSearch.new.event_counts( current_user )
    end

end
