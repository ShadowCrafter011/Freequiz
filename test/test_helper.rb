ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def sign_in(username, password = nil)
        password ||= username
        post user_login_path, params: { username:, password: }
        assert_response :redirect
    end

    def language_id(name)
        Language.where(name:).first.id
    end

    def user_params
        {
            username: "ABC",
            email: "abc@freequiz.ch",
            password: "hallO123",
            password_confirmation: "hallO123",
            agb: "1"
        }
    end

    def user_params_with(**kwargs)
        params = user_params
        kwargs.each { |key, value| params[key.to_sym] = value }
        params
    end
end
