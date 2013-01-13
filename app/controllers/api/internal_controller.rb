class Api::InternalController < ApplicationController

    # This method will do its best to retrieve all events following an event represented by the supplied
    # event id. This method is not completely accurate, as it is difficult to determine cardinality in this
    # case because of the asynchronous nature of the remote logging api. Events that happened earlier can
    # be delayed over the wire and be stored at a later time.
    def events_tail
        @selected_format = cookies[ :selected_format ]

        last_event = Event.find( params[ :last_id ] )

        query_options = build_query_options( { :order => [ "timestamp desc", "_id desc" ], :limit => 30 } )

        if ( last_event )

            # We need to be careful here since the timestamp condition may have already been specified
            query_options[ :timestamp ] = {} if query_options[ :timestamp ].nil?
            if ( query_options[ :timestamp ][ :$lte ].nil? or query_options[ :timestamp ][ :$lte ] < last_event.timestamp )
                query_options[ :timestamp ][ :$lte ] = last_event.timestamp
            end
            
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

            # We need to be careful here since the timestamp condition may have already been specified
            query_options[ :timestamp ] = {} if query_options[ :timestamp ].nil?
            if ( query_options[ :timestamp ][ :$gte ].nil? or query_options[ :timestamp ][ :$gte ] > first_event.timestamp )
                query_options[ :timestamp ][ :$gte ] = first_event.timestamp
            end

            query_options[ :_id ] = { :$gt => first_event.id }

            events = Event.find_for_user( current_user, query_options ).reverse

            render :partial => "events/formats/#{@selected_format}", :collection => events, :as => :event
        else
            render :nothing => true
        end
    end

    def event_stacktrace
        event = Event.find( params[ :id ] )

        if event.nil?
            render :nothing => true, :status => :not_found
        else
            formatted_stacktrace = event.stack_trace

            render :text => "<pre class='formatted_stacktrace'>#{formatted_stacktrace}</pre>"
        end
    end

    # This method will match users ( first name, last name, and email ) to the term supplied on the
    # params via params[ :term ] and return a collection of objects with highlighted values. The terms
    # parameter will be tokenized and or'd. In addition to supplying a term filter, an option parameter
    # 'include_groups=true' can be supplied to include groups on the results.
    def user_list
        users = []

        if not params[ :term ].blank?
            terms      = params[ :term ].split(/\s+/)
            regex_term = Regexp.new( "(#{terms.join("|")})", "i" )

            result     = User.where({
                :$or => [
                    { :email => regex_term },
                    { :first_name => regex_term },
                    { :last_name => regex_term }
                ]
            }).fields( :id, :first_name, :last_name, :email ).collect do |u|
                {
                    :id => u.id,
                    :name => "#{u.first_name} #{u.last_name}".strip.gsub( regex_term, '<b>\1</b>' ),
                    :email => u.email.strip.gsub( regex_term, '<b>\1</b>' ),
                    :type => u.class.name.downcase
                }
            end

            if params[ :include_groups ] == "true"
                result += UserGroup.where( :name => regex_term ).fields( :id, :name ).collect do |g|
                    {
                        :id => g.id,
                        :name => g.name,
                        :type => g.class.name.downcase
                    }
                end

            end

        end

        render :json => result
    end

private

    def build_query_options( query_options )        
        query_options[ :application_id ]   = cookies[ :selected_application_id ] unless cookies[ :selected_application_id ].blank?
        query_options[ :module_name ]      = cookies[ :selected_module_name ] unless cookies[ :selected_module_name ].blank?
        query_options[ :environment_name ] = cookies[ :selected_environment_name ] unless cookies[ :selected_environment_name ].blank?
        query_options[ :log_level ]        = cookies[ :selected_log_level ] unless cookies[ :selected_log_level ].blank?            
        
        # Ensure we only retrieve application the current user has access to
        visible_app_ids = Application.visible_by_user( current_user ).fields( :id ).collect { |app| app.id.to_s }

        if not visible_app_ids.include? query_options[ :application_id ]
            query_options.delete( :application_id )
            cookies[ :selected_application_id ] = nil
        end

        # If we don't have a specific application selected, ensuer we only return ones the current user can see
        if query_options[ :application_id ].nil?
            query_options[ :application_id ] = visible_app_ids
        end

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

                query_options[ :timestamp ] = { :$lte => date }
            else
                logger.warn "Invalid date format #{selected_date_from}"
            end
        end        

        return query_options
    end

end
