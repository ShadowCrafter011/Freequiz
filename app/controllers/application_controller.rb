class ApplicationController < ActionController::Base
    before_action :setup_login
    around_action :switch_locale

    def locale_en(&action)
        I18n.with_locale(:en, &action)
    end

    def switch_locale(&action)
        if (locale = session[:locale]).present?
            I18n.with_locale(locale, &action)
        else
            locale = logged_in? ? @user.setting.locale.to_sym : cookies[:locale]
            locale ||= I18n.default_locale
            I18n.with_locale(locale, &action)
            session[:locale] = locale
        end
    end

    def tp(attribute, replace = nil, html_safe: false)
        translated =
            t(
                "#{@locale[:path]}#{@locale[:action_override] ? "" : ".#{action_name}"}.#{attribute}"
            )
        return html_safe ? translated.html_safe : translated if replace.nil?

        replaced = translated.sub("%s", replace.to_s)
        html_safe ? replaced.html_safe : replaced
    end
    alias tl tp
    helper_method :tp, :tl

    def tg(attribute, pre = "")
        t "general.#{pre}#{pre.present? ? "." : ""}#{attribute}"
    end
    helper_method :tg

    def setup_locale(base_path)
        @locale = { path: "#{base_path}.", action_override: false }
    end

    def override_action(action)
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
        true
    end

    def require_admin!
        return unless require_login!

        render "errors/not_allowed" unless @user.admin?
    end

    def user_admin?
        logged_in? && @user.admin?
    end
    helper_method :user_admin?

    def current_user
        @user
    end
    helper_method :current_user

    def gn(**messages)
        %i[s a n].each do |key|
            unless messages[key].present?
                messages[key] = []
                next
            end
            messages[key] = [messages[key]] if messages[key].is_a? String
        end

        session[:notifications] = messages
    end

    def test_id(id)
        "data-test-id=\"#{id}\"".html_safe unless Rails.env.production?
    end
    helper_method :test_id

    private

    def login
        @user = User.find_signed cookies.encrypted[:_session_token], purpose: :login
        @user.present?
    end
end
