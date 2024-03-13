class User::SessionsController < ApplicationController
    before_action { setup_locale "user.sessions" }

    def new
        if logged_in?
            gn n: tp("already_logged_in")
            redirect_to user_path
        end
        @return_path = params[:gg]
    end

    def create
        override_action "new"

        user = User.where("lower(username) = ?", params[:username].downcase)

        user = [User.find_by(email: params[:username].downcase)] unless user.first

        unless user.first && user.length == 1
            gn a: tp("wrong_username")
            return render :new, status: :unprocessable_entity
        end

        if user.first.login params[:password]
            remember = params[:remember] == "1"
            expires_in = remember ? 20.years : 1.days
            token = user.first.signed_id(purpose: :login, expires_in:)

            cookies.encrypted.permanent[:_session_token] = token if remember
            cookies.encrypted[:_session_token] = token unless remember

            gn s: tp("success").sub("%s", user.first.username)

            user.first.sign_in request.remote_ip
            # Reset the locale in session store to allow the saved one to take over
            session[:locale] = nil
            redirect_to(params[:gg].present? ? params[:gg] : user_path)
        else
            gn a: tp("wrong_password")
            render :new, status: 401
        end
    end

    def destroy
        cookies.delete :_session_token
        session[:locale] = nil
        gn n: tp("success")
        redirect_to user_login_path
    end
end
