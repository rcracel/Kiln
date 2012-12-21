class EventsController < ApplicationController

    def index
        @applications = Event.collection.distinct( :application_name )
        @environments = Event.collection.distinct( :environment_name )

        selected_application = cookies[ :selected_application_name ]
        selected_environment = cookies[ :selected_environment_name ]

        options = { :order => "timestamp desc", :limit => 20 }

        if ( @applications.include? selected_application )
            options[:application_name] = selected_application
        end

        if ( @environments.include? selected_environment )
            options[:environment_name] = selected_environment
        end

        @events       = Event.all options
    end


end
