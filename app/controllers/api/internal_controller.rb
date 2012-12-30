class Api::InternalController < ApplicationController

    # This method will do its best to retrieve all events following an event represented by the supplied
    # event id. This method is not completely accurate, as it is difficult to determine cardinality in this
    # case because of the asynchronous nature of the remote logging api. Events that happened earlier can
    # be delayed over the wire and be stored at a later time.
    def events_tail
        @selected_format = cookies[ :selected_format ]

        last_event = Event.find( params[ :last_id ] )

        query_options = build_query_options( { :order => [ "timestamp desc", "_id desc" ], :limit => 30 } )

        if ( params[ :last_id ] )
            query_options[ :timestamp ] = { :$lte => last_event.timestamp }
            query_options[ :_id ] = { :$lt => last_event.id }
        end

        events = Event.find_for_user( current_user, query_options )

        render :partial => "events/formats/#{@selected_format}", :collection => events, :as => :event
    end

    # This method will do its best to retrieve all event items with a timestamp more recent than the
    # one for the specified id. This can be tricky, as the log events are coming over the wire and
    # there is no guarantee on which ones will be saved first. We can look at timestamp, but this
    # is a flawed method since we can have several log events with the same timestamp, where some 
    # of these events may have been stored on the database after the initial request
    def events_head
        @selected_format = cookies[ :selected_format ]

        first_event = Event.find( params[ :first_id ] )

        if ( first_event )
            query_options    = build_query_options( { :order => [ "timestamp asc", "_id asc" ], :limit => 200 } )

            query_options[ :timestamp ] = { :$gte => first_event.timestamp }
            query_options[ :_id ] = { :$gt => first_event.id }

            events = Event.find_for_user( current_user, query_options ).reverse

            render :partial => "events/formats/#{@selected_format}", :collection => events, :as => :event
        else
            render :nothing => true
        end
    end

private

    def build_query_options( query_options )        
        query_options[ :application_id ]   = cookies[ :selected_application_id ] unless cookies[ :selected_application_id ].blank?
        query_options[ :module_name ]      = cookies[ :selected_module_name ] unless cookies[ :selected_module_name ].blank?
        query_options[ :environment_name ] = cookies[ :selected_environment_name ] unless cookies[ :selected_environment_name ].blank?
        query_options[ :log_level ]        = cookies[ :selected_log_level ] unless cookies[ :selected_log_level ].blank?            
        
        # As usual, dates are more complicated....
        selected_date_from = cookies[ :selected_date_from ]
        if ( not selected_date_from.blank? )
            # do some sanitizing first
            selected_date_from = selected_date_from.strip.gsub(/\\/, "-").gsub(/\s+/, " ")

            matches = /^(\d{1,2})\-(\d{1,2})\-(\d{4})(?:\s+(\d{1,2}):(\d{1,2}))?$/.match selected_date_from
            if matches
                date = nil

                if matches[4].nil? # time not specified
                    date = Time.zone.local( matches[3].to_i, matches[1].to_i, matches[2].to_i ) + 24.hours - 1.seconds
                else
                    date = Time.zone.local( matches[3].to_i, matches[1].to_i, matches[2].to_i, matches[4].to_i, matches[5].to_i )
                end

                query_options[:timestamp] = { :$lte => date }
            else
                logger.warn "Invalid date format #{selected_date_from}"
            end
        end        

        return query_options
    end

end
