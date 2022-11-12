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
            return true
        end
        return false
    end

    def require_login!
        unless logged_in?
            redirect_to(user_login_path(gg: request.path))
            return false
        end
        return true
    end

    def current_user
        User.find(cookies.encrypted[:_session_token].to_s.split(";")[0])
    end

    def gn **messages
        for key in [:s, :a, :n] do
            unless messages[key].present?
                messages[key] = []
                next
            end
            messages[key] = [messages[key]] if messages[key].is_a? String
        end

        session[:notifications] = messages
    end
end
