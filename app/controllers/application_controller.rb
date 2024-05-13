class ApplicationController < ActionController::Base
    before_action :setup_login
    around_action :switch_locale

    def locale_en(&)
        I18n.with_locale(:en, &)
    end

    def switch_locale(&)
        if (locale = session[:locale]).present?
            I18n.with_locale(locale, &)
        else
            locale = logged_in? ? @user.setting.locale.to_sym : cookies[:locale]
            locale ||= I18n.default_locale
            I18n.with_locale(locale, &)
            session[:locale] = locale
        end
    end

    def tp(attribute, **args)
        t(
            "#{@locale[:path]}#{@locale[:action_override] ? "" : ".#{action_name}"}.#{attribute}",
            **args
        )
    end
    alias tl tp
    helper_method :tp, :tl

    def tg(attribute, pre = "", **args)
        t("general.#{pre}#{pre.present? ? "." : ""}#{attribute}", **args)
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
            redirect_to user_login_path(gg: request.path), alert: tg("login_required")
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
