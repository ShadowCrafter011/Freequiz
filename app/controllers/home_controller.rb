class HomeController < ApplicationController
    before_action { setup_locale "home" }

    def search
        results = Quiz.search_all_quizzes params
        @quizzes = results.first
        @pages = results.last
        @params = quiz_search_params
    end

    def root
        @new_quizzes = Quiz.order(created_at: :desc).limit(5)

        return unless logged_in?

        @quizzes = @user.quizzes.order(created_at: :desc).limit(5)
    end

    def sponsors; end

    def apple_association; end

    private

    def quiz_search_params
        params.permit(:title, :sort, :commit, :page)
    end
end
