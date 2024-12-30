require "test_helper"

class QuizReportTest < ActiveSupport::TestCase
    test "should not save quiz report without quiz_id" do
        quiz_report = QuizReport.new
        assert_not quiz_report.save
    end

    test "status should be open by default" do
        quiz_report = QuizReport.new(quiz: quizzes(:one))
        assert_equal "open", quiz_report.status
    end

    test "status can be solved" do
        quiz_report = QuizReport.new(quiz: quizzes(:one), status: "solved")
        assert quiz_report.valid?
    end

    test "status can be ignored" do
        quiz_report = QuizReport.new(quiz: quizzes(:one), status: "ignored")
        assert quiz_report.valid?
    end
end
