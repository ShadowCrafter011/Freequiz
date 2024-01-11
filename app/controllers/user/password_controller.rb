class User::PasswordController < ApplicationController
    before_action { setup_locale "user.password" }

    def reset; end

    def send_email
        override_action "reset"

        user = User.where("lower(username) = ?", params[:username].downcase)

        user = [User.find_by(email: params[:username].downcase)] unless user.first

        unless user.first && user.length == 1
            gn a: tp("wrong_username")
            return render :reset, status: 401
        end

        user.first.send_reset_password_email
        gn s: tp("sent_email")
        redirect_to root_path
    end

    def edit
        user =
            User.find_signed params[:password_reset_token], purpose: :reset_password
        return if user.present?

        gn a: tp("invalid_link")
        redirect_to root_path
    end

    def update
        override_action "edit"

        user =
            User.find_signed params[:password_reset_token], purpose: :reset_password
        unless user.present?
            gn a: tp("invalid_link")
            return redirect_to root_path
        end

        unless params[:password].match?(
            /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}\z/
        )
            gn a: tg("password_regex")
            return render :edit, status: :unprocessable_entity
        end

        if user.update(
            password: params[:password],
            password_confirmation: params[:password_confirmation]
        )
            user.encrypt_password

            expires_in = 14.days
            token = user.signed_id(purpose: :login, expires_in:)

            cookies.encrypted[:_session_token] = {
                value: token,
                expires: Time.now + expires_in
            }

            user.sign_in request.remote_ip

            gn s: tp("changed_password")
            redirect_to user_path
        else
            gn a: user.get_errors
            render :edit, status: :unprocessable_entity
        end
    end
end
