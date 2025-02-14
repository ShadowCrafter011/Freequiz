require "test_helper"

class Api::QuizControllerTest < ActionDispatch::IntegrationTest
    test "create quiz" do
        assert_changes "Quiz.count" do
            put api_quiz_create_path, params: { quiz: {
                title: "Test Quiz",
                from: language_id(:german),
                to: language_id(:english),
                visibility: "public",
                translations_attributes: [{ word: "Baum", translation: "Tree" }]
            } }, headers: api_sign_in(:one)
            assert_response :success
        end

        assert_equal 1, @response.parsed_body["quiz_data"]["data"].length
    end

    test "cannot create quiz when not logged in" do
        assert_no_changes "Quiz.count" do
            put api_quiz_create_path, params: { quiz: {
                title: "Test Quiz",
                from: language_id(:german),
                to: language_id(:english),
                visibility: "public",
                translations_attributes: [{ word: "Baum", translation: "Tree" }]
            } }
            assert_response :unauthorized
        end
    end

    test "search quizzes" do
        get api_quiz_search_path, params: { query: "Test" }
        assert_response :success
    end
end
