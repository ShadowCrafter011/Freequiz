class UserMailer < ApplicationMailer
    def verification_email
        email = params[:email]
        @username = params[:username]
        @token = params[:token]
        mail(to: email, subject: "Bestätigen Sie Ihre E-Mail Adresse")
    end
end
