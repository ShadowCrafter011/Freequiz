class User::UserController < ApplicationController
    before_action { setup_locale "user.user" }
    before_action :require_login!, except: %i[new create public change_lang]

    def show
        @user_data = {
            tg("username") => @user.username,
            tg("email") => @user.email,
            tp("data.unconfirmed_email") => @user.unconfirmed_email,
            tp("data.email_verified") => @user.verified? ? tg("c_yes") : tg("c_no"),
            tg("role") => tg("roles.#{@user.role}")
        }.compact

        @login_data = {
            tp("data.total_logins") => @user.sign_in_count,
            tp("data.last_at") => @user.current_sign_in_at
        }
    end

    def public
        @target = User.find_by(username: params[:username])
        @quizzes = @target.quizzes.where("visibility = 'public'")
    end

    def quizzes
        result = Quiz.search_user_quizzes @user, params
        @quizzes = result.first
        @pages = result.last
        @params = user_quizzes_params
    end

    def library; end

    def new
        if logged_in?
            gn n: tp("already_has_account")
            return redirect_to user_path
        end

        @new_user = User.new
    end

    def create
        override_action "new"

        @new_user = User.new(user_params)

        unless user_params[:password].match?(
            /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}\z/
        )
            gn a: tg("password_regex")
            return render :new, status: :unprocessable_entity
        end

        @new_user.current_sign_in_ip = request.remote_ip
        @new_user.current_sign_in_at = Time.now

        if @new_user.save
            expires_in = 14.days
            token = @new_user.signed_id(purpose: :login, expires_in:)

            cookies.encrypted[:_session_token] = {
                value: token,
                expires: Time.now + expires_in
            }

            gn s: tp("created").sub("%s", @new_user.username)

            redirect_to user_verification_pending_path
        else
            gn a: @new_user.get_errors
            render :new, status: :unprocessable_entity
        end
    end

    def edit; end

    def update
        override_action "edit"

        if edit_params[:password].present? && !edit_params[:password].match?(
            /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}\z/
        )
            gn a: tg("password_regex")
            return render :edit, status: :unprocessable_entity
        end

        email_changed, errors = @user.change(edit_params)
        if errors.length.positive?
            gn a: errors
            render :edit, status: :unprocessable_entity
        else
            messages = [tp("saved_data")]
            messages.append(tp("new_email")) if email_changed
            gn s: messages
            redirect_to user_path
        end
    end

    def settings; end

    def change_lang
        if logged_in?
            @user.setting.update locale: params[:locale] if Setting::LOCALES.include? params[:locale]

            session[:locale] = @user.setting.locale
        else
            cookies.permanent[:locale] = params[:locale]
            session[:locale] = params[:locale]
        end
        redirect_to params[:return_to]
    end

    def update_settings
        @user.setting.update(setting_params)
        gn s: tp("saved")

        session[:locale] = @user.setting.locale

        redirect_to user_settings_path
    end

    def request_destroy
        @token = @user.signed_id purpose: :destroy_user, expires_in: 1.day
    end

    def destroy
        user = User.find_signed params[:destroy_token], purpose: :destroy_user

        if user.present? && user == @user
            @user.destroy
            gn n: tp("deleted")
            redirect_to root_path
        else
            gn a: tp("failed")
            redirect_to user_path
        end
    end

    private

    def user_params
        params.require(:user).permit(
            :username,
            :email,
            :password,
            :password_confirmation,
            :agb
        )
    end

    def edit_params
        params.require(:user).permit(
            :username,
            :email,
            :password,
            :password_confirmation,
            :old_password
        )
    end

    def setting_params
        params.require(:setting).permit(Setting::SETTING_KEYS, :locale)
    end

    def user_quizzes_params
        params.permit(:title, :sort, :commit, :page)
    end
end
