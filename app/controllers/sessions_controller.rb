class SessionsController < ApplicationController

    skip_before_filter :authorize, :only => [ :new, :create, :destroy ]

    def new
        render "new", :layout => "plain"
    end

    def create
        user = User.find_by_email(params[:email])
        if user && user.authenticate(params[:password])
            session[:user_id] = user.id
            redirect_to root_url, notice: "Welcome back!"
        else
            flash.now.alert = "Email or password is invalid"
            render "new", :layout => "plain"
        end
    end

    def destroy
        session[:user_id] = nil
        redirect_to login_path, notice: "Logged out!"
    end    
    
end
