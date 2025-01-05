require "test_helper"

class Api::UserControllerTest < ActionDispatch::IntegrationTest
    test "blocked username validation" do
        get api_username_validator_path("Freequiz")

        json = @response.parsed_body

        assert json["success"]
        assert_not json["valid"]
        assert_equal "username.blocked", json["token"]
    end

    test "taken username validation" do
        get api_username_validator_path("one")

        json = @response.parsed_body

        assert json["success"]
        assert_not json["valid"]
        assert_equal "username.taken", json["token"]
    end

    test "valid username validation" do
        get api_username_validator_path("test")

        json = @response.parsed_body

        assert json["success"]
        assert json["valid"]
    end

    test "user creation" do
        assert_difference("User.count", 1) do
            assert_emails 1 do
                put api_user_create_path, params: { user: { username: "test", password: "Password123", password_confirmation: "Password123", email: "test@freequiz.ch", agb: true } }
            end
        end

        json = @response.parsed_body

        assert json["success"]
        assert_equal User.find_by(username: "test").id, User.find_signed(json["access_token"], purpose: :api_token).id
    end

    test "user creation with missing data" do
        assert_no_difference("User.count") do
            put api_user_create_path, params: { user: {} }
        end

        assert_not @response.parsed_body["success"]
    end

    test "user creation with one missing field" do
        user_params = {
            username: "test",
            password: "Password123",
            password_confirmation: "Password123",
            email: "test@freequiz.ch",
            agb: true
        }

        user_params.each_key do |key|
            assert_no_difference("User.count") do
                put api_user_create_path, params: { user: user_params.except(key) }
            end

            assert_not @response.parsed_body["success"]
        end
    end

    test "user creation with invalid password" do
        passwords = %w[
            password
            password123
            Password
            abc
            AB123c
        ]

        passwords.each do |password|
            assert_no_difference("User.count") do
                put api_user_create_path, params: { user: {
                    username: "test",
                    password: password,
                    password_confirmation: password,
                    email: "test@freequiz.ch",
                    agb: true
                } }

                assert_not @response.parsed_body["success"]
            end
        end
    end

    test "user creation with non-matching passwords" do
        assert_no_difference("User.count") do
            put api_user_create_path, params: { user: {
                username: "test",
                password: "Password123",
                password_confirmation: "Password1234",
                email: "test@freequiz.ch",
                agb: true
            } }

            assert_not @response.parsed_body["success"]
        end
    end

    test "user creation with invalid email" do
        emails = %w[
            test
            test@freequiz.
            abc@abc_.
        ]

        emails.each do |email|
            assert_no_difference("User.count") do
                put api_user_create_path, params: { user: {
                    username: "test",
                    password: "Password123",
                    password_confirmation: "Password123",
                    email: email,
                    agb: true
                } }

                assert_not @response.parsed_body["success"]
            end
        end
    end

    test "user creation without accepting AGB" do
        assert_no_difference("User.count") do
            put api_user_create_path, params: { user: {
                username: "test",
                password: "Password123",
                password_confirmation: "Password123",
                email: "test@freequiz.ch"
            } }
        end
    end

    test "user creation with blocked username" do
        assert_no_difference("User.count") do
            put api_user_create_path, params: { user: {
                username: "Freequiz",
                password: "Password123",
                password_confirmation: "Password123",
                email: "test@freequiz.ch",
                agb: true
            } }

            assert_not @response.parsed_body["success"]
        end
    end

    test "user creation with taken username" do
        assert_no_difference("User.count") do
            put api_user_create_path, params: { user: {
                username: "one",
                password: "Password123",
                password_confirmation: "Password123",
                email: "test@freequiz.ch",
                agb: true
            } }

            assert_not @response.parsed_body["success"]
        end
    end

    test "username existance check" do
        get api_user_exists_path(attr: "username", query: "one")

        json = @response.parsed_body

        assert json["success"]
        assert json["exists"]
    end

    test "email existance check" do
        # get api_user_exists_path(attr: "email", query: "one@one.one")

        # json = @response.parsed_body

        # assert json["success"], "Request should be successful"
        # assert json["exists"], "Email should exist"
    end
end
