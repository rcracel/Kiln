class UsersController < ApplicationController

    skip_before_filter :authorize, :only => [ :signup, :do_signup, :forgot_password, :do_forgot_password, :reset_password, :do_reset_password ]

    def signup
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

    def do_signup
        # Prevent a user currently logged in to create a new account
        if ( not current_user.nil? )
            redirect_to root_path
        end

        if ( not APP_CONFIG['allow_new_users'] )
            flash[ :warn ] = "User registration has been disabled by the system administrator"
            redirect_to login_path and return
        end

        @user = User.new( params[:user] )

        # Auto provision and make admin the first user to register on the site
        if ( User.count == 0 )
            @user.roles = [ :user, :admin ]
        end

        if @user.save
            AccountEmailer.registration_email( @user ).deliver

            session[:user_id] = @user.id

            redirect_to root_url, notice: "Thank you for signing up!"
        else
            render "new", :layout => "plain"
        end
    end

    def forgot_password
        render "forgot_password", :layout => "plain"
    end

    def do_forgot_password
        user = User.first( :email => params[ :email ] )

        if user.nil?
            flash.now[ :error ] = "Email address not found, please enter the email address associated with your account"
            render "forgot_password", :layout => "plain"
        else
            token = PasswordResetToken.new
            token.token = UUIDTools::UUID.random_create.to_s
            token.expires = Time.now + 12.hours

            user.password_reset_token = token
            
            if user.save
                AccountEmailer.password_reset_token( user ).deliver
                flash[ :info ] = "You will receive an email shortly with instructions on how to reset your password"
            else
                flash[ :alert ] = "Could not create a password reset token, please contact the system administrator for assistance"                
            end

            redirect_to login_path
        end
    end

    def reset_password
        render "reset_password", :layout => "plain"
    end

    def do_reset_password
        user = User.first( { :email => params[ :email ], "password_reset_token.token" => params[ :reset_token ], "password_reset_token.expires" => { :$gte => Time.now } } )

        if user.nil?
            flash.now[ :error ] = "Invalid email address or password reset token, please ensure that you have provided the correct email address associated with your account"
            render "reset_password", :layout => "plain"
        else
            user.password_reset_token = nil
            user.update_attributes params

            if user.save
                flash[ :info ] = "Your password has been successfully reset, please login using your new password"
                redirect_to login_path
            else
                flash.now[ :error ] = "Could not reset your password, please contact the system administrator if the problem persists"
            end
        end
    end

end
