require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  # setup do
  #   Rails.application.routes.default_url_options[:host] = Capybara.current_session.server.host
  #   Rails.application.routes.default_url_options[:port] = Capybara.current_session.server.port
  # end

  test "visiting the index" do
    puts "before!!!"
    visit root_url
    puts "AFTER£"

    assert_selector "h1", text: "Wilkommen bei Freequiz!"
  end
end
