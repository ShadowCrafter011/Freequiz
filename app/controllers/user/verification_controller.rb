class User::VerificationController < ApplicationController
  before_action :require_login!

  def verify
    token = params[:verification_token]
    user = current_user

    if Time.now > user.confirmation_expire
      gn a: "Dieser Link ist abgelaufen"
      return redirect_to user_path
    end

    if user.compare_encrypted :confirmation_token, token
      user.confirmed = true
      user.confirmed_at = Time.now
      user.confirmation_token = nil
      user.save

      gn s: "E-mail Adresse erfolgreich bestätigt!"
      redirect_to user_path
    else
      gn a: "Dieser Link ist nicht gültig"
      redirect_to user_path
    end
  end
end
