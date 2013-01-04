class AccountEmailer < ActionMailer::Base
    
    default from: "webmaster@nevermindsoft.com"

    def registration_email( user )
        @user = user

        mail( :to => user.email, :subject => "Thank you for Registering", :template => "email" )
    end

    def password_reset_email( user )
        recipients  user.email
        from        "webmaster@nevermindsoft.com"
        subject     "Password Reset Requested"
        body        :user => user
    end

end
