class UserMailer < ApplicationMailer
    def verification_email
        @user = params[:user]
        mail(to: @user.email, subject: "Bestätigen Sie Ihre E-Mail Adresse")
    end
end
