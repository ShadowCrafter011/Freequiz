class Admin::UsersController < ApplicationController
    before_action :require_admin!

    def index
        return(@users = User.order(created_at: :desc)) unless params.key? :commit

        if params[:type].present? && params[:type] == "query"
            property = params[:property] == "username" ? "username" : "email"
            safe_query = ActiveRecord::Base.connection.quote_string(params[:query])

            valid_sort = %w[created_at updated_at confirmed_at last_sign_in_at]
            valid_direction = %w[ASC DESC]

            sort = valid_sort.include?(params[:sort]) ? params[:sort] : "created_at"
            direction =
                valid_direction.include?(params[:order]) ? params[:order] : "ASC"

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
        @token = @user_target.signed_id purpose: :destroy_user, expires_in: 1.day
    end

    def destroy
        user = User.find_signed params[:destroy_token], purpose: :destroy_user

        if user.present?
            user.destroy
            flash.notice = "User deleted"
        else
            flash.alert = "Could not delete user. Retry again later"
        end
        redirect_to admin_users_path
    end

    def update
        user = User.find_by(username: params[:username])

        was_verified = user.verified?
        email_before = user.email

        unless user.update(edit_params)
            flash.now.alert = ["Failed to save user for the following reasons"].concat(
                user.get_errors
            )
            return render :edit, status: :unprocessable_entity
        end

        user.update(confirmed_at: Time.now) if edit_params[:confirmed] && !was_verified

        if edit_params[:email] != email_before || (!user.verified? && was_verified)
            user.update(confirmed: false, confirmed_at: nil)
            user.send_verification_email
            flash.notice = "Saved user and verification E-mail was sent"
        else
            flash.notice = "Saved user"
        end
        redirect_to admin_user_edit_path(user.username)
    end

    def send_verification
        user = User.find_by(username: params[:username])
        sent = user.send_verification_email
        notice = sent ? "Verification E-mail sent to user (#{user.email})" : "Verification E-mail wasn't sent because either the user is already verified or something went wrong"
        redirect_to admin_user_edit_path(user.username), notice:
    end

    def send_password_reset
        user = User.find_by(username: params[:username])
        user.send_reset_password_email
        redirect_to admin_user_edit_path(user.username), notice: "Password reset E-mail sent to user (#{user.email})"
    end

    def prepare_email
        @user = User.find_by(username: params[:username])
    end

    def send_email
        user = User.find_by(username: params[:username])
        AdminMailer
            .with(email: user.email, subject: params[:subject], body: params[:body])
            .email_to_user
            .deliver_later
        redirect_to admin_user_edit_path(user.username), notice: "E-mail sent to user (#{user.email})"
    end

    private

    def edit_params
        params.require(:user).permit(
            :username,
            :email,
            :unconfirmed_email,
            :role,
            :confirmed
        )
    end
end
