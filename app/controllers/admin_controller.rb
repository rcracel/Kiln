class AdminController < ApplicationController

    before_filter :require_admin, :except => :users

    def users
        @users = User.all
    end

    def confirm_delete_user
        @user = User.find( params[ :id ] )

        if @user == current_user
            redirect_to user_list_path, :flash => { :warn => "You cannot delete yourself" }
        end           
    end

    def do_delete_user
        user = User.find( params[ :id ] )

        if user == current_user
            redirect_to user_list_path, :flash => { :warn => "You cannot delete yourself" }
        else
            flash[ :error ] = "Could not delete selected user" unless user.delete
            redirect_to user_list_path
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

        redirect_to user_list_path
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

        redirect_to user_list_path
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

            redirect_to user_list_path, :notice => "User has been created. An email will be sent to #{@user.email} with instructions on how to complete the registration process"
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

        redirect_to user_list_path, :flash => { :info => "User #{user.email} has been authorized and can now access the application" }
    end

    def deauthorize_user
        user = User.find( params[ :id ] )

        if user.roles.include? :user
            user.roles.delete :user
            user.save
        end

        redirect_to user_list_path, :flash => { :info => "User #{user.email} has been authorized and can now access the application" }
    end

end
