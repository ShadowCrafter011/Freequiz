class Api::DocsController < ApplicationController
    before_action :require_admin!

    def index; end

    def users; end

    def quizzes; end

    def languages; end

    def authentication; end

    def general_errors; end

    def bugs; end
end
