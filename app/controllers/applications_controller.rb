class ApplicationsController < ApplicationController

    def index
        @applications = Application.visible_by_user( current_user )
        @application  = Application.new( params[ :application ] )
    end

    def create
        @applications = Application.visible_by_user( current_user )
        @application  = Application.new( params[ :application ] )

        @application.owner = current_user

        if @application.save
            redirect_to applications_path
        else
            render "index"
        end
    end

    def authorized_users
        @application = Application.find params[ :id ]

        if @application.owner != current_user
            flash[ :error ] = "You are not authorized to modify permissions for #{application.name}"
            redirect_to applications_path
        end

    end

    def update_authorized_users
        application = Application.find params[ :id ]

        if application.owner != current_user
            flash[ :error ] = "You are not authorized to modify permissions for #{application.name}"
        else
            users = params["users"]

            application.authorized_users = []

            if not users.nil?
                users.each do |user_id|
                    application.authorized_users << User.find( user_id )
                end
            end

            if application.save
                flash[ :info ] = "Successfully updated permissions for #{application.authorized_users.length} users on #{application.name}"
            else
                flash[ :warn ] = "Cound not update permissions for #{application.name}"
            end

        end

        redirect_to applications_path
    end

end
