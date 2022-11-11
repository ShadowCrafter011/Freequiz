class ApplicationController < ActionController::Base
    def logged_in?
        User.exists? cookies.encrypted[:_session_token]
    end

    def require_login!
        unless User.exists? cookies.encrypted[:_session_token]
            redirect_to(user_login_path(goto: request.path))
            return false
        end
        return true
    end

    def current_user
        User.find(cookies.encrypted[:_session_token])
    end

    def generate_notification **messages
        session[:alert] = messages[:alert] if messages[:alert].present?
        session[:success] = messages[:success] if messages[:success].present?
        session[:notice] = messages[:notice] if messages[:notice].present?
    end

    def gn **messages
        generate_notification :notice => messages[:n], :alert => messages[:a], :success => messages[:s]
    end
end
