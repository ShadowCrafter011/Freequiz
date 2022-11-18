class ApplicationController < ActionController::Base
    def tg attribute
        t "general.#{attribute}"
    end

    def tl attribute
        t "controller.#{controller_name}.#{action_name}.#{attribute}"
    end
    
    def logged_in?
        logged_in = login
        return logged_in
    end
    helper_method :logged_in?
    
    def require_login!
        unless login
            redirect_to(user_login_path(gg: request.path))
            return false
        end
        return true
    end
    
    # must be sure that login or require_login! returns true
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

    private
        def login
            return false unless cookies.encrypted[:_session_token].present?
            data = cookies.encrypted[:_session_token].to_s.split(";")
            if User.exists?(data[0])
                user = User.find(data[0])
                unless Time.now.to_i < data[1].to_i
                    cookies.delete :_session_token
                    return false
                end
                @user = user
                return true
            end
            return false
        end
end
