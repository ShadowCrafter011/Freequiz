require "test_helper"

class QuizTest < ActiveSupport::TestCase
    test "can create quiz" do
        assert Quiz.new(
            title: "Quiz",
            description: "Description",
            from: language_id("german"),
            to: language_id("french"),
            visibility: "public",
            translations_attributes: [
                { word: "Baum", translation: "Arbre" }
            ]
        ).save
    end

    test "cannot create quiz without translations" do
        assert_not Quiz.new(
            title: "Quiz",
            description: "Description",
            from: language_id("german"),
            to: language_id("french"),
            visibility: "public"
        ).save
    end
end
