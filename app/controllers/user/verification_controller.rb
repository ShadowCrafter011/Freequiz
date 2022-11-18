class User::VerificationController < ApplicationController
  before_action :require_login!

  def verify
    token = params[:verification_token]

    if Time.now > @user.confirmation_expire
      return redirect_to user_verification_success_path(expired: 1)
    end

    if @user.compare_encrypted :confirmation_token, token

      if @user.verified? && @user.unconfirmed_email.present?
        @user.email = @user.unconfirmed_email
        @user.unconfirmed_email = nil
      else
        @user.confirmed = true
      end

      @user.confirmed_at = Time.now
      @user.confirmation_token = nil
      @user.confirmation_expire = nil
      @user.save

      redirect_to user_verification_success_path
    else
      redirect_to user_verification_success_path(invalid: 1)
    end
  end

  def success
    if (params[:expired].present? || params[:invalid].present?) && @user.verified?
      redirect_to user_verification_success_path
    end
  end

  def pending
    if @user.verified?
      gn n: "Deine E-Mail Adresse wurde schon bestätigt"
      redirect_to user_path
    end
  end

  def send_email
    if @user.send_verification_email
      gn s: "Bestätigungs E-mail wurde geschickt. Sie sollte in wenigen Minuten in ihrem Postfach ankommen. Folgen Sie dann den Anweisungen in der E-mail"
    else
      gn a: "Ihre E-mail Adresse ist schon bestätigt"
    end
    redirect_to user_path
  end
end
