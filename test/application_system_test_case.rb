require "test_helper"
require "webdrivers"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
    driven_by :selenium, using: :headless_chrome

    def find_test_id(test_id)
        find(:test_id, test_id)
    end

    def create_user_with(
        visit: true,
        username: "Test",
        email: "test@freequiz.ch",
        password: "hallO123",
        password_confirmation: "hallO123",
        agb: true
    )
        visit user_create_url if visit

        fill_in I18n.t("user.user.new.username"), with: username
        fill_in I18n.t("user.user.new.email"), with: email
        fill_in I18n.t("user.user.new.password"), with: password
        fill_in I18n.t("user.user.new.repeat_password"), with: password_confirmation
        check I18n.t "user.user.new.accept_agb" if agb
        click_on I18n.t "user.user.new.submit_create_account"
    end
    alias create_user create_user_with

    def add_user_to_db
        User.create username: "Test",
                    password: "hallO123",
                    email: "test@freequiz.ch",
                    agb: true,
                    role: "beta"
    end

    def t(key)
        I18n.t key
    end

    def login(password: "hallO123")
        visit user_login_url
        assert_text I18n.t "user.sessions.new.login_page"

        fill_in I18n.t("general.email_or_username"), with: "Test"
        fill_in I18n.t("general.password"), with: password
        click_on I18n.t("user.sessions.new.login")
    end

    def close_notice
        click_on id: "close-notice"
    end
end
