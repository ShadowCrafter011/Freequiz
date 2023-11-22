class User::VerificationController < ApplicationController
  before_action :require_login!, except: :verify

  before_action do
    setup_locale "user.verification"
  end

  def verify
    @user = User.find_signed params[:verification_token], purpose: :verify_email

    if @user.present?
      if @user.verified? && @user.unconfirmed_email.present?
        @user.email = @user.unconfirmed_email
        @user.unconfirmed_email = nil
      else
        @user.confirmed = true
      end

      @user.confirmed_at = Time.now
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
      gn n: tp("already_verified")
      redirect_to user_path
    end
  end

  def send_email
    override_action "pending"

    if @user.send_verification_email
      gn s: tp("sent")
    else
      gn a: tp("already_verified")
    end
    redirect_to user_path
  end
end
