class WelcomeController < ApplicationController

    def index
        @chart_data = {}

        visible_apps    = Application.visible_by_user( current_user )
                                     .fields( :id, :name )

        @chart_data[ :event_count_for_app ]    = {}
        @chart_data[ :events_count_by_module ] = {}
        @chart_data[ :events_count_by_level ]  = {}

        visible_apps_ids = visible_apps.collect { |a| a.id }

        counter = Event.collection.group(
            [ :application_id, :module_name, :log_level ],
            { :application_id => { :$in => visible_apps_ids } },
            { :count => 0 },
            "function( doc, prev ) { prev.count++ }",
            true
        )

        counter.each do |g|
            app   = visible_apps.select.find { |a| a.id.to_s == g['application_id'].to_s }
            count = g['count']

            if @chart_data[ :event_count_for_app ][ app.name ].nil?
                @chart_data[ :event_count_for_app ][ app.name ] = 0
            end
            @chart_data[ :event_count_for_app ][ app.name ] += count

            module_name = g['module_name']

            if @chart_data[ :events_count_by_module ][ module_name ].nil?
                @chart_data[ :events_count_by_module ][ module_name ] = count
            else
                @chart_data[ :events_count_by_module ][ module_name ] += count
            end

            log_level = g['log_level']
                
            if @chart_data[ :events_count_by_level ][ log_level ].nil?
                @chart_data[ :events_count_by_level ][ log_level ] = count
            else
                @chart_data[ :events_count_by_level ][ log_level ] += count
            end

        end

    end

end
