class AdminMailer < ApplicationMailer
    def email_to_user
        @body = params[:body]
        mail(to: params[:email], subject: params[:subject])
    end
end
