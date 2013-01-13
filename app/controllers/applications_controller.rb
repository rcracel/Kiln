class ApplicationsController < ApplicationController

    def index
        @applications      = Application.sort( :name )
        @application       = Application.new( params[ :application ] )
        @application.owner = current_user
    end

    def create
        index

        if @application.save
            redirect_to applications_path
        else
            render "index"
        end
    end

    def authorized_users
        @application = Application.find params[ :id ]
        @authorized_objects = @application.authorized_users + @application.authorized_groups

        if @application.owner == current_user or current_user.roles.include? :admin
        else
            flash[ :error ] = "You are not authorized to modify permissions for #{@application.name}"
            redirect_to applications_path
        end

    end

    def update_authorized_users
        application = Application.find params[ :id ]

        if application.owner == current_user or current_user.roles.include? :admin
            users  = params["users"]
            groups = params["groups"]

            application.authorized_users = []

            if not users.nil?
                users.each do |user_id|
                    application.authorized_users << User.find( user_id )
                end
            end

            application.authorized_groups = []

            if not groups.nil?
                groups.each do |group_id|
                    application.authorized_groups << UserGroup.find( group_id )
                end
            end

            if application.save
                flash[ :info ] = "Successfully updated permissions for #{application.authorized_users.length} users on #{application.name}"
            else
                flash[ :warn ] = "Cound not update permissions for #{application.name}"
            end
        else
            flash[ :error ] = "You are not authorized to modify permissions for #{application.name}"
        end

        redirect_to applications_path
    end

end
