require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  def create_user_with(visit: true, username: "Test", email: "test@freequiz.ch", password: "hallO123", password_confirmation: "hallO123", agb: true)
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
    User.create username: "Test", password: "hallO123", email: "test@freequiz.ch", agb: true
  end

  def login password: "hallO123"
    visit user_login_url
    assert_text I18n.t "user.sessions.new.login_page"

    fill_in I18n.t("general.email_or_username"), with: "Test"
    fill_in I18n.t("general.password"), with: password
    click_on I18n.t("user.sessions.new.login")
  end

  test "creating account" do
    visit root_url
    assert_text I18n.t "home.root.welcome"

    click_on I18n.t "layouts.application.account"
    click_on I18n.t "layouts.application.create"
    assert_text I18n.t "user.user.new.create_account"

    create_user_with visit: false

    assert_text I18n.t("user.user.new.created").sub("%s", "Test")
    assert User.find_by(username: "Test").present?
  end

  test "no account with same username or email" do
    create_user
    create_user
    assert_text I18n.t "activerecord.errors.models.user.attributes.username.taken"
    assert_text I18n.t "activerecord.errors.models.user.attributes.email.taken"
  end

  test "login" do
    add_user_to_db
    login

    assert_text I18n.t("user.sessions.new.success").sub("%s", "Test")

    visit user_url
    assert_text I18n.t("user.user.show.title")

    visit user_login_url
    assert_text I18n.t("user.sessions.new.already_logged_in")

    visit user_logout_url
    assert_text I18n.t("user.sessions.destroy.success")

    visit user_url
    assert_text I18n.t("general.login_required")
  end

  test "editing account" do
    add_user_to_db
    login

    click_on I18n.t "user.user.show.buttons.edit"
    assert_text I18n.t("user.user.edit.title")

    fill_in I18n.t("general.username"), with: "Edited"
    click_on I18n.t "general.save"
    assert_text I18n.t "user.user.show.title"
    assert_equal "Edited", User.find_by(email: "test@freequiz.ch").username

    click_on I18n.t "user.user.show.buttons.edit"
    fill_in I18n.t("general.password"), with: "HelloWorld42"
    fill_in I18n.t("user.user.edit.password_repeat"), with: "HelloWorld41"
    fill_in I18n.t("user.user.edit.old_password"), with: "hallo123"
    click_on I18n.t "general.save"
    assert_text I18n.t("errors.old_password_no_match")

    fill_in I18n.t("general.password"), with: "HelloWorld42"
    fill_in I18n.t("user.user.edit.password_repeat"), with: "HelloWorld41"
    fill_in I18n.t("user.user.edit.old_password"), with: "hallO123"
    click_on I18n.t "general.save"
    assert_text I18n.t("activerecord.errors.models.user.attributes.password.confirmation")

    fill_in I18n.t("general.username"), with: "Test"
    fill_in I18n.t("general.password"), with: "HelloWorld42"
    fill_in I18n.t("user.user.edit.password_repeat"), with: "HelloWorld42"
    fill_in I18n.t("user.user.edit.old_password"), with: "hallO123"
    click_on I18n.t "general.save"
    assert_text I18n.t("user.user.edit.saved_data")
    assert User.find_by(username: "Test").present?

    visit user_logout_url
    login
    assert_text I18n.t("user.sessions.new.wrong_password")

    login password: "HelloWorld42"
    assert_text I18n.t("user.sessions.new.success").sub("%s", "Test")
  end

  # test "deleting account" do
    
  # end
end
