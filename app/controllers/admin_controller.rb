class AdminController < ApplicationController

    before_filter :require_admin, :except => :users

    def users
        @users = User.all
    end

    def confirm_delete_user
        @user = User.find( params[ :id ] )
    end

    def do_delete_user
        user = User.find( params[ :id ] )

        flash[ :error ] = "Could not delete selected user" unless user.delete
    end

end
