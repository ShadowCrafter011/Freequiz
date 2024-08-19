require "test_helper"

class UserTest < ActiveSupport::TestCase
    test "do not create user without data" do
        user = User.new
        assert_not user.save
    end

    test "user accept agb" do
        user = User.new user_params_with(agb: "0")
        assert_not user.save
    end

    test "user password match" do
        user = User.new user_params_with(password_confirmation: "HallOO123")
        assert_not user.save
    end

    test "create user" do
        user = User.new user_params
        assert user.save
    end

    test "do not create users with the same username" do
        User.create user_params
        user = User.new user_params_with(email: "diekillerdrone788@gmail.com")

        assert_not user.save
    end

    test "do not create users with the same email" do
        User.create user_params
        user = User.new user_params_with(username: "hello")
        assert_not user.save
    end

    test "email downcase" do
        user = User.create(user_params_with(email: "lkoE@blUEwin.cH"))
        assert_equal "lkoe@bluewin.ch", user.email
    end

    test "role on creation" do
        user = User.create(user_params)
        assert_equal user.role, "user"
    end

    test "sign in count" do
        user = User.create(user_params)
        assert_equal user.sign_in_count, 1
    end
end
