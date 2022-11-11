class UserMailer < ApplicationMailer
    def verification_email
        @user = params[:user]
        mail(to: @user.email, subject: "Bestätigen sie Ihre E-Mail Adresse")
    end
end
