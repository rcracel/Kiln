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
        if current_user.nil?
            redirect_to login_url, alert: "You must log in to access the requested page"
        elsif not current_user.roles.include? :user
            redirect_to login_url, alert: "Your account has not been authorized yet"
        end
    end

    def require_admin
        if not current_user.roles.include? :admin
            redirect_to events_path, :flash => { :error => "You must be an administrator to perform this function" }
        end
    end

    def user_time_zone( &block )
        Time.use_zone( current_user.timezone, &block )
    end

end
