class ApplicationController < ActionController::Base
    before_action :setup_login
    around_action :switch_locale

    def switch_locale(&action)
        if (locale = cookies[:locale]).present?
            I18n.with_locale(locale, &action)
        else
            locale = logged_in? ? @user.setting.locale.to_sym : I18n.default_locale
            I18n.with_locale(locale, &action)
            cookies[:locale] = locale
        end
    end
    
    def tp(attribute, replace=nil, html_safe=false)
        translated = t("#{@locale[:path]}#{@locale[:action_override] ? "" : ".#{action_name}"}.#{attribute}")
        if replace == nil
            return html_safe ? translated.html_safe : translated
        end

        replaced = translated.sub("%s", replace)
        html_safe ? replaced.html_safe : replaced
    end
    helper_method :tp

    def tg pre="", attribute
        t "general.#{pre}#{pre.present? ? "." : ""}#{attribute}"
    end
    helper_method :tg

    def setup_locale base_path
        @locale = {
            path: "#{base_path}.",
            action_override: false
        }
    end

    def override_action action
        @locale[:path] += action.to_s
        @locale[:action_override] = true
    end

    def setup_login
        login
    end

    def logged_in?
        @user.present?
    end
    helper_method :logged_in?

    def require_login!
        unless logged_in?
            gn a: t("general.login_required")
            redirect_to(user_login_path(gg: request.path))
            return false
        end
        return true
    end

    def require_admin!
        return unless require_login!
        render "errors/not_allowed" unless @user.admin?
    end
    
    def current_user
        @user
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
        @user = nil
        return false unless cookies.encrypted[:_session_token].present?
        data = cookies.encrypted[:_session_token].to_s.split(";")

        # Using find_by because find will throw an exception if the user doesn't exists. Find_by returns nil
        @user = User.find_by(id: data[0])
        unless Time.now.to_i < data[1].to_i
            cookies.delete :_session_token
            return false
        end
        return @user.present?
    end
end
