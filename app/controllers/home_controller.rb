class HomeController < ApplicationController
    before_action { setup_locale "home" }

    def search
        results = Quiz.search_all_quizzes params
        @quizzes = results.first
        @pages = results.last
        @params = quiz_search_params
    end

    def root; end

    def sponsors; end

    private

    def quiz_search_params
        params.permit(:title, :sort, :commit, :page)
    end
end
