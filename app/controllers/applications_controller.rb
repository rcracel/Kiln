class ApplicationsController < ApplicationController

    def index
        @applications = Application.where( owner_id: current_user.id )
        @application  = Application.new( params[ :application ] )
    end

    def create
        @applications = Application.where( owner_id: current_user.id )
        @application  = Application.new( params[ :application ] )

        @application.owner = current_user

        logger.info "HEre... #{current_user}"

        if @application.save
            redirect_to applications_path
        else
            render "index"
        end
    end

end
