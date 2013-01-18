class EventsController < ApplicationController

    def index

        logger.info "Selected Format: #{cookies[ :selected_format ]}"

        @formats = [ [ "Kiln Default", "default_format" ], [ "Single Line", "single_line_format" ], [ "Verbose", "verbose_format" ] ]
        @selected_format = if @formats.find { |a| a[1] == cookies[ :selected_format ] }
            cookies[ :selected_format ]
        else
            cookies[ :selected_format ] = @formats.first[ 1 ]            
        end

        # Get list of all applications and resolve currently selected one
        @applications = Application.visible_by_user( current_user ).collect { |a| [ a.name, a.id.to_s ] }
        selected_application_id = unless ( @applications.find { |a| a[1] == cookies[ :selected_application_id ] } )
            cookies[ :selected_application_id ] = nil
        end

        # Get a list of all modules for currently selected application and resolve currently selected module
        @modules = Event.module_name_list( cookies[ :selected_application_id ] )
        selected_module_name = unless ( @modules.include? cookies[ :selected_module_name ] )
            cookies[ :selected_module_name ] = nil
        end

        # Get a list of all environment names for the currently selected application + module and resolve the
        # currently selected environment
        @environments = Event.environment_name_list( cookies[ :selected_application_id ], cookies[ :selected_module_name ] )
        selected_environment_name = unless ( @environments.include? cookies[ :selected_environment_name ] )
            cookies[ :selected_environment_name ] = nil
        end

        # Get a list of all log levels for the currently selected application + module + environment and resolve
        # the currently selected log level
        @log_levels = Event.log_level_list( cookies[ :selected_application_id ], cookies[ :selected_module_name ], cookies[ :selected_environment_name ] )
        selected_log_level = unless ( @log_levels.include? cookies[ :selected_log_level ] )
            cookies[ :selected_log_level ] = nil
        end
    end

end
