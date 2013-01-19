class EventSearch

    def initialize

    end


    def daily_usage_map

    end

    def weekly_usage_map( number_of_weeks = 7 )
        event_graph_data     = []
        end_of_previous_week = Time.now.at_beginning_of_day - Time.now.wday.days + 1.week
        applications         = Application.fields( :id, :name ).all

        # Build the header for the table
        header = [ "Week" ]
        applications.each do |app|
            header << app.name
        end
        event_graph_data << header

        # Build the rows for the table
        number_of_weeks.downto( 0 ) do |offset|
            end_date   = end_of_previous_week - offset.weeks
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

private

    def logger
        Rails.logger
    end

end