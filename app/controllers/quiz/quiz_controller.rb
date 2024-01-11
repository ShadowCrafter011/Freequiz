class Quiz::QuizController < ApplicationController
    include QuizUtils
    include ApiUtils

    before_action :require_login!, :require_beta! do
        setup_locale "quiz.quiz"
    end

    before_action only: %i[cards learn] do
        override_action :show

        @access_token = generate_access_token(current_user, 5.days.from_now.to_i)

        @quiz = Quiz.find_by(uuid: params[:quiz_uuid])
        unless @quiz.present? && @quiz.user_allowed_to_view?(current_user)
            gn n: tp("not_found")
            redirect_to root_path
        end
    end

    def cards; end

    def write; end

    def new
        @quiz = current_user.quizzes.new
    end

    def create
        override_action :new

        @quiz = current_user.quizzes.new(quiz_params)
        if @quiz.save
            gn s: tp("quiz_created")
            redirect_to quiz_show_path(@quiz.uuid)
        else
            gn a: @quiz.get_errors
            render :new, status: :unprocessable_entity
        end
    end

    def show
        @quiz = Quiz.find_by(uuid: params[:quiz_uuid])

        unless @quiz.present?
            gn n: tp("not_found")
            return redirect_to root_path
        end

        nil unless check_viewing_privilege
    end

    def request_destroy
        @quiz = Quiz.find_by(uuid: params[:quiz_uuid])

        if @quiz.present? && @user == @quiz.user
            @token = SecureRandom.hex(32)
            @quiz.update(destroy_token: @token, destroy_expire: 1.day.from_now)
            @quiz.encrypt_value :destroy_token
        else
            redirect_to root_path
        end
    end

    def edit
        override_action "new"

        @quiz = @user.quizzes.find_by(uuid: params[:quiz_uuid])

        return if @quiz.present?

        gn n: tp("not_found")
        redirect_to root_path
    end

    def update
        override_action "new"

        @quiz = @user.quizzes.find_by(uuid: params[:quiz_uuid])

        unless @quiz.present?
            gn n: tp("not_found")
            redirect_to root_path
        end

        if @quiz.update(quiz_params)
            gn s: tp("saved")
            redirect_to quiz_show_path(@quiz.uuid)
        else
            gn a: @quiz.get_errors
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        quiz = @user.quizzes.find_by(uuid: params[:quiz_uuid])
        token = params[:destroy_token]

        unless quiz.present?
            gn n: tp("not_found")
            redirect_to root_path
        end

        if quiz.user == @user && quiz.compare_encrypted(:destroy_token, token) &&
           quiz.destroy_expire > Time.now
            quiz.destroy
            gn n: tp("deleted")
        else
            gn a: tp("not_allowed")
        end
        redirect_to root_path
    end

    private

    def quiz_params
        params.require(:quiz).permit(
            :title,
            :description,
            :from,
            :to,
            :visibility,
            data: %i[w t]
        )
    end

    def require_beta!
        return unless require_login!

        render "errors/beta_wall" unless @user.beta? || @user.admin?
    end
end
