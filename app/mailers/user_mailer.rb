class UserMailer < ApplicationMailer
    def verification_email
        @username = params[:username]
        @token = params[:token]
        mail(to: params[:email], subject: "Bestätigen Sie Ihre E-Mail Adresse")
    end

    def password_reset_email
        @username = params[:username]
        @token = params[:token]
        mail(to: params[:email], subject: "Passwort zurücksetzen")
    end
end
