class EventsController < ApplicationController

    def index

        logger.info "Selected Format: #{cookies[ :selected_format ]}"

        @formats = [ [ "Kiln Default", "default_format" ], [ "Single Line", "single_line_format" ], [ "Verbose", "verbose_format" ] ]
        @selected_format = if @formats.find { |a| a[1] == cookies[ :selected_format ] }
            cookies[ :selected_format ]
        else
            cookies[ :selected_format ] = @formats.first[ 1 ]            
        end

        options = { :order => "timestamp desc", :limit => 20 }

        # Get list of all applications and resolve currently selected one
        @applications = Application.all.collect { |a| [ a.name, a.id.to_s ] }
        selected_application_id = if ( @applications.find { |a| a[1] == cookies[ :selected_application_id ] } )
            options[ :application_id ] = cookies[ :selected_application_id ]            
        else
            cookies[ :selected_application_id ] = nil
        end

        # Get a list of all modules for currently selected application and resolve currently selected module
        @modules = Event.module_name_list( selected_application_id )
        selected_module_name = if ( @modules.include? cookies[ :selected_module_name ] )
            options[ :module_name ] = cookies[ :selected_module_name ]
        else
            cookies[ :selected_module_name ] = nil
        end

        # Get a list of all environment names for the currently selected application + module and resolve the
        # currently selected environment
        @environments = Event.environment_name_list( selected_application_id, selected_module_name )
        selected_environment_name = if ( @environments.include? cookies[ :selected_environment_name ] )
            options[ :environment_name ] = cookies[ :selected_environment_name ]
        else
            cookies[ :selected_environment_name ] = nil
        end

        # Get a list of all log levels for the currently selected application + module + environment and resolve
        # the currently selected log level
        @log_levels = Event.log_level_list( selected_application_id, selected_module_name, selected_environment_name )
        selected_log_level = if ( @log_levels.include? cookies[ :selected_log_level ] )
            options[ :log_level ] = cookies[ :selected_log_level ]
        else
            cookies[ :selected_log_level ] = nil
        end

        selected_date_from   = cookies[ :selected_date_from ]

        if ( selected_date_from.nil? == false )
            begin
                timezone = current_user.timezone.nil? ? 
                                Time.zone : 
                                ActiveSupport::TimeZone.new( current_user.timezone )

                date = timezone.parse( selected_date_from, "%mm-%dd-%YYYY" )

                options[:timestamp] = { :$gte => date, :$lte => (date + 24.hours) } unless date.nil?
            rescue Exception => e
                logger.error "*********** Something wrong happened : #{e.message} for #{selected_date_from}"
            end

        end

        @events       = Event.all( options )
    end




end
