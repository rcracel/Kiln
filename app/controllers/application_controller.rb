class ApplicationController < ActionController::Base

    before_filter :authorize

    around_filter :user_time_zone, if: :current_user

    protect_from_forgery

private

    def current_user
        @current_user ||= User.find( session[ :user_id ] ) if session[:user_id]
    end

    helper_method :current_user

    def authorize
        redirect_to login_url, alert: "Not authorized" if current_user.nil?
    end

    def user_time_zone( &block )
        Time.use_zone( current_user.timezone, &block )
    end

end
