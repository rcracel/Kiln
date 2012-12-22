class EventsController < ApplicationController

    def index
        @applications = Event.collection.distinct( :application_name )
        @environments = Event.collection.distinct( :environment_name )
        @log_levels   = Event.collection.distinct( :log_level )

        selected_application = cookies[ :selected_application_name ]
        selected_environment = cookies[ :selected_environment_name ]
        selected_log_level   = cookies[ :selected_log_level ]

        options = { :order => "timestamp desc", :limit => 20 }

        if ( @applications.include? selected_application )
            options[:application_name] = selected_application
        end

        if ( @environments.include? selected_environment )
            options[:environment_name] = selected_environment
        end

        if ( @log_levels.include? selected_log_level )
            options[:log_level] = selected_log_level
        end

        @events       = Event.all options
    end


end
