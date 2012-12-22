class AccountController < ApplicationController

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    logger.info "--------------- #{params[ :user ]}"

    current_user.update_attributes( params[ :user ] )

    if @user.save
        redirect_to dashboard_path
    else
        render "edit"
    end

  end
  
end
