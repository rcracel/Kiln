class Api::InternalController < ApplicationController

    def events
        query_options    = { :order => "timestamp desc", :limit => 30 }

        @selected_format = cookies[ :selected_format ]

        query_options[ :_id ]              = { :$lt => BSON::ObjectId.from_string( params[ :last_id ] ) } unless ( params[ :last_id ].blank? )
        query_options[ :application_id ]   = cookies[ :selected_application_id ] unless cookies[ :selected_application_id ].blank?
        query_options[ :module_name ]      = cookies[ :selected_module_name ] unless cookies[ :selected_module_name ].blank?
        query_options[ :environment_name ] = cookies[ :selected_environment_name ] unless cookies[ :selected_environment_name ].blank?
        query_options[ :log_level ]        = cookies[ :selected_log_level ] unless cookies[ :selected_log_level ].blank?            
        
        # As usual, dates are more complicated....
        selected_date_from = cookies[ :selected_date_from ]
        if ( not selected_date_from.blank? )
            # do some sanitizing first
            selected_date_from = selected_date_from.strip.gsub(/\\/, "-").gsub(/\s+/, " ")

            # determine validity
            if ( selected_date_from.match /^\d{1,2}\-\d{1,2}\-\d{4} \d{1,2}:\d{1,2}$/ )
                timezone = current_user.timezone.nil? ? 
                                Time.zone : 
                                ActiveSupport::TimeZone.new( current_user.timezone )

                date = timezone.parse( selected_date_from, "%mm-%dd-%YYYY %hh:%MM" )
                options[:timestamp] = { :$gte => date, :$lte => (date + 24.hours) } unless date.nil?
            else
                logger.error "Invalid date format #{cookies[ :selected_date_from ]}"
            end
        end        

        events = Event.find_for_user( current_user, query_options )

        render :partial => "events/formats/#{@selected_format}", :collection => events, :as => :event
    end

end
