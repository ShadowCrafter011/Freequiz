class ApplicationController < ActionController::Base
    def tp(attribute, replace: nil, html_safe: false)
        translated = t("#{@locale[:path]}#{@locale[:action_override] ? "" : ".#{action_name}"}.#{attribute}")
        if replace == nil
            return html_safe ? translated.html_safe : translated
        end

        replaced = translated.sub("%s", replace)
        html_safe ? replaced.html_safe : replaced
    end
    helper_method :tp

    def tg attribute
        t "general.#{attribute}"
    end
    helper_method :tg

    def setup_locale base_path
        @locale = {
            path: "#{base_path}.",
            action_override: false
        }
    end

    def override_action action
        @locale[:path] += action
        @locale[:action_override] = true
    end

    def override_locale locale
        @locale = {
            path: locale,
            action_override: true
        }
    end

    def require_admin!
        return unless require_login!
        render "errors/not_allowed" unless @user.admin?
    end
    
    def logged_in?
        logged_in = login
        return logged_in
    end
    helper_method :logged_in?
    
    def require_login!
        unless login
            gn a: t("general.login_required")
            redirect_to(user_login_path(gg: request.path))
            return false
        end
        return true
    end
    
    # must be sure that login or require_login! returns true
    def current_user
        User.find(cookies.encrypted[:_session_token].to_s.split(";")[0])
    end
    helper_method :current_user
    
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
