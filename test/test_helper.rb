ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors, with: :threads)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def user_params
    {
      username: "Lukas",
      email: "lkoe@bluewin.ch",
      password: "hallO123",
      password_confirmation: "hallO123",
      agb: "1"
    }
  end

  def user_params_with **kwargs
    params = user_params
    kwargs.each do |key, value|
      params[key.to_sym] = value
    end
    return params
  end
end
