class AdminController < ApplicationController

    before_filter :require_admin

    def home
    end

    def info
        @stats = {}

        now = Time.now

        @stats['event_count']            = Event.count
        @stats['event_count_today']      = Event.where({ :timestamp => { :$gte => (now.at_beginning_of_day) } }).count
        @stats['event_count_past_week']  = Event.where({ :timestamp => { :$gte => (now - 1.week) } }).count
        @stats['event_count_past_month'] = Event.where({ :timestamp => { :$gte => (now - 1.month) } }).count

        @stats['event_graph_data'] = EventSearch.new.weekly_usage_map

        @applications = Application.all
    end

    ########################################
    # User Groups

    def groups
        @groups = UserGroup.all
        @group  = UserGroup.new params[ :user_group ]
    end

    def do_create_group
        groups

        if @group.save
            if params[ :go_to_users ]
                redirect_to manage_group_users_path( @group )
            else
                redirect_to group_management_path
            end
        else
            render "groups", :flash => { :error => "Could not save user group, please correct any errors and try again" }
        end
    end

    def delete_group
        @group = UserGroup.find params[ :id ]

        render "confirm_delete_group"
    end

    def do_delete_group
        UserGroup.delete params[ :id ]

        redirect_to group_management_path
    end

    def group_users
        @group = UserGroup.find params[ :id ]
    end

    def update_group_users
        group = UserGroup.find params[ :id ]

        users = params["users"]

        group.users = []

        if not users.nil?
            users.each do |user_id|
                group.users << User.find( user_id )
            end
        end

        if group.save
            flash[ :info ] = "Successfully group #{group.name} with #{group.users.length} #{"user".pluralize(group.users.length)}"
        else
            flash[ :warn ] = "Cound not update group #{group.name}"
        end

        redirect_to group_management_path
    end

    ########################################
    # Users

    def users
        @users = User.all
    end

    def confirm_delete_user
        @user = User.find( params[ :id ] )

        if @user == current_user
            redirect_to user_management_path, :flash => { :warn => "You cannot delete yourself" }
        end           
    end

    def do_delete_user
        user = User.find( params[ :id ] )

        if user == current_user
            redirect_to user_management_path, :flash => { :warn => "You cannot delete yourself" }
        else
            Application.where( { :owner_id => user.id } ).each do |a|
                logger.warn "Changing ownership for #{a.name} to #{current_user.name}"
                a.owner = current_user
                a.save
            end

            UserGroup.where( { :user_ids => current_user.id } ).each do |g|
                logger.warn "Removing user #{user.name} from group #{g.name}"
                g.user_ids.delete( user.id )
                g.save
            end

            flash[ :error ] = "Could not delete selected user" unless user.delete
            redirect_to user_management_path
        end
    end

    def promote_user
        user = User.find( params[ :id ] )

        if not user.roles.include? :admin
            user.roles << :admin

            if user.save
                flash[ :info ] = "User #{user.email} is now an administrator"
            else
                flash[ :warn ] = "Could promote user #{user.email}"
            end
        else
            flash[ :warn ] = "User #{user.email} is already an admin"
        end

        redirect_to user_management_path
    end

    def demote_user
        user = User.find( params[ :id ] )

        if user == current_user
            flash[ :warn ] = "You cannot demote yourself"
        elsif not user.roles.include? :admin
            flash[ :warn ] = "User #{user.email} is not an admin"
        else
            user.roles.delete :admin

            if user.save
                flash[ :info ] = "User #{user.email} is no longer an administrator"
            else
                flash[ :warn ] = "Could not demote user #{user.email}"
            end
        end

        redirect_to user_management_path
    end

    def create_user
        @user = User.new
    end

    def do_create_user
        @user = User.new params[ :user ]

        # Generate a random password for the user
        o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
        @user.password =  @user.password_confirmation = (0...50).map{ o[rand(o.length)] }.join

        # User created by an admin is automatically authorized
        @user.roles = [ :user ]

        if @user.save
            AccountEmailer.registration_email( @user ).deliver

            redirect_to user_management_path, :notice => "User has been created. An email will be sent to #{@user.email} with instructions on how to complete the registration process"
        else
            render "create_user", :flash => { :error => "Could not save user, please correct any errors and try again" }
        end
    end

    def authorize_user
        user = User.find( params[ :id ] )

        if not user.roles.include? :user
            user.roles << :user
            user.save
        end

        redirect_to user_management_path, :flash => { :info => "User #{user.email} has been authorized and can now access the application" }
    end

    def deauthorize_user
        user = User.find( params[ :id ] )

        if user.roles.include? :user
            user.roles.delete :user
            user.save
        end

        redirect_to user_management_path, :flash => { :info => "User #{user.email} has been authorized and can now access the application" }
    end

    ########################################
    # Applications

    def apps
        @applications      = Application.sort( :name )
        @application       = Application.new( params[ :application ] )
        @application.owner = current_user

        render "/applications/index"
    end

    def confirm_delete_app
        @application = Application.find params[ :id ]
    end

    def do_delete_app
        application = Application.find( params[ :id ] )

        Event.destroy_all( { :application_id => application.id } )
        application.destroy

        redirect_to application_management_path
    end

    def confirm_reassign_app
        @application = Application.find params[ :id ]
    end

    def do_reassign_app
        application = Application.find params[ :id ]
        new_owner   = User.find params[ :user_id ]

        if new_owner.nil?
            confirm_reassign_app
            flash[ :now ] = "You must specify a valid user as the new owner for #{application.name}"
            render "confirm_reassign_app"
        else
            application.owner = new_owner

            if ( application.save )

            else
            end

            redirect_to application_management_path
        end
    end

end
