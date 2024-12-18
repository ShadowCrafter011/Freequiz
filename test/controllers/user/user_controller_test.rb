require "test_helper"

class User::UserControllerTest < ActionDispatch::IntegrationTest
    test "can visit sign up page" do
        get user_create_path
        assert_response :success
    end

    test "can visit public page" do
        get user_public_path(:one)
        assert_response :success
    end

    test "can change language without being logged in" do
        patch change_language_path, params: { locale: :de, return_to: "/" }
        assert_redirected_to "/"
    end

    test "do not redirect language change to other domain" do
        assert_raises(ActionController::Redirecting::UnsafeRedirectError) do
            patch change_language_path, params: { locale: :de, return_to: "https://google.com" }
        end
    end

    test "can create user" do
        assert_difference "User.count", 1 do
            assert_emails 1 do
                post user_create_path, params: { user: {
                    username: "Testing",
                    email: "testing@freequiz.ch",
                    password: "GoodPassword123",
                    password_confirmation: "GoodPassword123",
                    agb: true
                } }
                assert_redirected_to user_verification_pending_path
            end
        end
    end

    test "redirect from sign up page when logged in" do
        sign_in :two
        get user_create_path
        assert_redirected_to user_path
    end

    test "can get user show path" do
        sign_in :one
        get user_path
        assert_response :success
    end

    test "can view user public path" do
        get user_public_path(users(:one).username)
        assert_response :success
    end

    test "can view favorites" do
        sign_in :one
        get user_favorites_path
        assert_response :success
    end

    test "can view quizzes" do
        sign_in :one
        get user_quizzes_path
        assert_response :success
    end

    test "can view library" do
        sign_in :one
        get user_library_path
        assert_response :success
    end
end
