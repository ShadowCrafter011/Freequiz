class ApplicationController < ActionController::Base
    def logged_in?
        return false unless cookies.encrypted[:_session_token].present?
        data = cookies.encrypted[:_session_token].to_s.split(";")
        if User.exists?(data[0])
            user = User.find(data[0])
            unless Time.now.to_i < data[1].to_i
                cookies.delete :_session_token
                return false
            end
        end
        return true
    end

    def require_login!
        unless logged_in?
            redirect_to(user_login_path(goto: request.path))
            return false
        end
        return true
    end

    def current_user
        User.find(cookies.encrypted[:_session_token].split(";")[0])
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
