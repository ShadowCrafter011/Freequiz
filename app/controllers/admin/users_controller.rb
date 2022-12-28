class Admin::UsersController < ApplicationController
    before_action :require_admin!

    def index
        return (@users = User.order(created_at: :desc)) unless params.key? :commit

        if params[:query].present?
            property = params[:property] == "username" ? "username" : "email"
            safe_query = ActiveRecord::Base.connection.quote_string(params[:query])

            valid_sort = ["created_at", "updated_at", "confirmed_at", "last_sign_in_at"]
            valid_direction = ["ASC", "DESC"]

            sort = valid_sort.include?(params[:sort]) ? params[:sort] : "created_at"
            direction = valid_direction.include?(params[:order]) ? params[:order] : "ASC"

            query_order = Arel.sql("#{property} ILIKE '%#{safe_query}%' DESC")
            date_order = Arel.sql("#{sort} #{direction}")

            @users = User.order(query_order, date_order)
        else
            @users = User.order("#{params[:sort]} #{params[:order]}")
        end
    end

    def edit
        @user_target = User.find_by(username: params[:username])
    end

    def destroy_token
        @user_target = User.find_by(username: params[:username])
        @token = SecureRandom.hex(32)
        @user_target.update(destroy_token: @token, destroy_expire: 1.days.from_now)
        @user_target.encrypt_value :destroy_token
    end

    def destroy
        token = params[:destroy_token]
        user = User.find_by(username: params[:username])

        if user.compare_encrypted(:destroy_token, token) && user.destroy_expire > Time.now
            user.destroy
            gn n: "User deleted"
        else
            gn a: "Could not delete user. Retry again later"
        end
        redirect_to admin_users_path
    end

    def update
        user = User.find_by(username: params[:username])
        
        was_verified = user.verified?
        email_before = user.email

        unless user.update(edit_params)
            gn a: ["Failed to save user for the following reasons"].concat(user.get_errors)
            return render :edit, status: :unprocessable_entity
        end

        if edit_params[:confirmed] && !was_verified
            user.update(confirmed_at: Time.now, confirmation_token: nil, confirmation_expire: nil)
        end

        if edit_params[:email] != email_before || (!user.verified? && was_verified)
            user.update(confirmed: false, confirmed_at: nil)
            user.send_verification_email
            gn s: "Saved user and verification E-mail was sent"
        else
            gn s: "Saved user"
        end
        redirect_to admin_user_edit_path(user.username)
    end

    def send_verification
        user = User.find_by(username: params[:username])
        sent = user.send_verification_email
        gn s: "Verification E-mail sent to user (#{user.email})" if sent
        gn n: "Verification E-mail wasn't sent because either the user is already verified or something went wrong" unless sent
        redirect_to admin_user_edit_path(user.username)
    end

    def send_password_reset
        user = User.find_by(username: params[:username])
        user.send_reset_password_email
        gn s: "Password reset E-mail sent to user (#{user.email})"
        redirect_to admin_user_edit_path(user.username)
    end

    def prepare_email
        @user = User.find_by(username: params[:username])
    end

    def send_email
        user = User.find_by(username: params[:username])
        AdminMailer.with(email: user.email, subject: params[:subject], body: params[:body]).email_to_user.deliver_later
        gn s: "E-mail sent to user (#{user.email})"
        redirect_to admin_user_edit_path(user.username)
    end

    private
        def edit_params
            params.require(:user).permit(:username, :email, :unconfirmed_email, :role, :confirmed)
        end
end
