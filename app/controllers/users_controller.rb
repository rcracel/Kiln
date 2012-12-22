class UsersController < ApplicationController

    skip_before_filter :authorize, :only => [ :new, :create ]

    def new
        @user = User.new

        render "new", :layout => "plain"
    end

    def create
        @user = User.new( params[:user] )

        logger.info "User is #{@user}"

        if @user.save
            session[:user_id] = @user.id
            redirect_to root_url, notice: "Thank you for signing up!"
        else
            render "new", :layout => "plain"
        end
    end

end
