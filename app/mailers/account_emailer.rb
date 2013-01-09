class AccountEmailer < ActionMailer::Base
    
    default from: "webmaster@nevermindsoft.com"

    def registration_email( user )
        @user = user

        mail( :from => APP_CONFIG['site']['admin_email'], :to => user.email, :subject => "Thank you for Registering" )
    end

    def password_reset_email( user )
        @user = user

        mail( :from => APP_CONFIG['site']['admin_email'], :to => user.email, :subject => "Password Reset Requested" )
    end

end
