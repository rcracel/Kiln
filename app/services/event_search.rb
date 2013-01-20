class EventSearch

    def initialize

    end


    def daily_usage_map( number_of_days = 7 )
        event_graph_data  = []
        begin_of_today    = Time.now.at_beginning_of_day
        applications      = Application.fields( :id, :name ).all

        # Build the header for the table
        header = [ "Days" ]
        applications.each do |app|
            header << app.name
        end
        event_graph_data << header

        # Build the rows for the table
        weekdays = %w( Sunday Monday Tuesday Wednesday Thursday Friday Saturday )
        number_of_days.downto( 0 ) do |offset|
            start_time = begin_of_today - offset.days
            end_time   = start_time + 1.day            

            # Find the count for a current week
            counts = Event.collection.group({
                key: [ :application_id, :count ],
                cond: { :timestamp => { :$lt => end_time, :$gte => start_time }},
                initial: { :count => 0 },
                reduce: "function( doc, prev ) { prev.count++ }"
            })

            # Build the row for this week
            row = [ end_time.strftime( "%b %d" ) ]
            applications.each do |app|
                count = counts.select.find { |c| c['application_id'] == app.id }
                row << ( count.nil? ? 0 : count['count'] )
            end
            event_graph_data << row
        end

        return event_graph_data
    end

    def weekly_usage_map( number_of_weeks = 7 )
        event_graph_data = []
        end_of_last_week = Time.now.at_beginning_of_day - Time.now.wday + 1.week
        applications     = Application.fields( :id, :name ).all

        # Build the header for the table
        header = [ "Week" ]
        applications.each do |app|
            header << app.name
        end
        event_graph_data << header

        # Build the rows for the table
        number_of_weeks.downto( 0 ) do |offset|
            end_date   = end_of_last_week - offset.weeks
            start_date = end_date - 1.week

            # Find the count for a current week
            counts = Event.collection.group({
                key: [ :application_id, :count ],
                cond: { :timestamp => { :$lt => end_date, :$gte => start_date }},
                initial: { :count => 0 },
                reduce: "function( doc, prev ) { prev.count++ }"
            })

            # Build the row for this week
            row = [ end_date.strftime( "%m-%d" ) ]
            applications.each do |app|
                count = counts.select.find { |c| c['application_id'] == app.id }
                row << ( count.nil? ? 0 : count['count'] )
            end
            event_graph_data << row
        end

        return event_graph_data
    end

    def event_counts( user, categories = [ :event_count_for_app, :events_count_by_module, :events_count_by_level ] )
        event_stats = {}

        visible_apps    = Application.visible_by_user( user )
                                     .fields( :id, :name )

        event_stats[ :event_count_for_app ]    = {}
        event_stats[ :events_count_by_module ] = {}
        event_stats[ :events_count_by_level ]  = {}

        visible_apps_ids = visible_apps.collect { |a| a.id }

        counter = Event.collection.group({
            key: [ :application_id, :module_name, :log_level ],
            cond: { :application_id => { :$in => visible_apps_ids } },
            initial: { :count => 0 },
            reduce: "function( doc, prev ) { prev.count++ }"
        })

        counter.each do |g|
            app   = visible_apps.select.find { |a| a.id.to_s == g['application_id'].to_s }
            count = g['count']

            if categories.include? :event_count_for_app
                if event_stats[ :event_count_for_app ][ app.name ].nil?
                    event_stats[ :event_count_for_app ][ app.name ] = 0
                end
                event_stats[ :event_count_for_app ][ app.name ] += count
            end

            if categories.include? :events_count_by_module
                module_name = g['module_name']
                if event_stats[ :events_count_by_module ][ module_name ].nil?
                    event_stats[ :events_count_by_module ][ module_name ] = count
                else
                    event_stats[ :events_count_by_module ][ module_name ] += count
                end
            end

            if categories.include? :events_count_by_level
                log_level = g['log_level']                
                if event_stats[ :events_count_by_level ][ log_level ].nil?
                    event_stats[ :events_count_by_level ][ log_level ] = count
                else
                    event_stats[ :events_count_by_level ][ log_level ] += count
                end
            end
        end

        return event_stats
    end

private

    def logger
        Rails.logger
    end

end