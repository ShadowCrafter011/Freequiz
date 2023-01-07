module QuizUtils
    def check_viewing_privilege user=@user, quiz=@quiz
        unless quiz.user_allowed_to_view? user
            gn a: I18n.t("errors.not_allowed_to_view_quiz")
            redirect_to root_path
        end
        quiz.user_allowed_to_view? user
    end
end