class User::VerificationController < ApplicationController
  before_action :require_login!

  def verify
    token = params[:verification_token]
    user = current_user

    if Time.now > user.confirmation_expire
      return redirect_to user_verification_success_path(expired: 1)
    end

    if user.compare_encrypted :confirmation_token, token
      user.confirmed = true
      user.confirmed_at = Time.now
      user.confirmation_token = nil
      user.save

      redirect_to user_verification_success_path
    else
      redirect_to user_verification_success_path(invalid: 1)
    end
  end

  def success
    @user = current_user

    if (params[:expired].present? || params[:invalid].present?) && @user.verified?
      redirect_to user_verification_success_path
    end
  end
end
