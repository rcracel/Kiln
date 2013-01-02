class UsersController < ApplicationController

    skip_before_filter :authorize, :only => [ :new, :create ]

    def new
        # Prevent a user currently logged in to create a new account
        if ( not current_user.nil? )
            redirect_to root_path
        end

        if ( not APP_CONFIG['allow_new_users'] )
            flash[ :warn ] = "User registration has been disabled by the system administrator"
            redirect_to login_path and return
        end

        @user = User.new

        render "new", :layout => "plain"
    end

    def create
        # Prevent a user currently logged in to create a new account
        if ( not current_user.nil? )
            redirect_to root_path
        end

        if ( not APP_CONFIG['allow_new_users'] )
            flash[ :warn ] = "User registration has been disabled by the system administrator"
            redirect_to login_path and return
        end

        @user = User.new( params[:user] )

        @user.roles = [ :user ]
        if ( User.count == 0 )
            @user.roles << :admin
        end

        if @user.save
            session[:user_id] = @user.id
            redirect_to root_url, notice: "Thank you for signing up!"
        else
            render "new", :layout => "plain"
        end
    end

end
