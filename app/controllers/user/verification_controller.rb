class User::VerificationController < ApplicationController
    before_action :require_login!, except: :verify

    before_action { setup_locale "user.verification" }

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
        if (params[:expired].present? || params[:invalid].present?) &&
           @user.verified?
            redirect_to user_verification_success_path
        end
    end

    def pending
        return unless @user.verified?

        redirect_to user_path, notice: tp("already_verified")
    end

    def send_email
        override_action "pending"

        redirect_to user_path, notice: @user.send_verification_email ? tp("sent") : tp("already_verified")
    end
end
