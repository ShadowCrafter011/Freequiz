class Quiz::QuizController < ApplicationController
    include ApiUtils

    before_action :require_login!, :require_beta! do
        setup_locale "quiz.quiz"
    end

    before_action only: %i[cards learn] do
        override_action :show

        @access_token = generate_access_token(current_user, 5.days.from_now.to_i)

        @quiz = Quiz.find_by(uuid: params[:quiz_uuid])
        redirect_to root_path, notice: tp("not_found") unless @quiz.present? && @quiz.user_allowed_to_view?(current_user)
    end

    def cards; end

    def learn; end

    def write; end

    def new
        @quiz = @user.quizzes.new
        4.times { @quiz.translations.build }
    end

    def create
        override_action :new

        @quiz = @user.quizzes.new(quiz_params)
        if @quiz.save
            redirect_to quiz_show_path(@quiz.uuid), notice: tp("quiz_created")
        else
            puts @quiz.get_errors
            4.times { @quiz.translations.build } if @quiz.translations.count.zero?
            render :new, status: :unprocessable_entity
        end
    end

    def show
        @quiz = Quiz.find_by(uuid: params[:quiz_uuid])

        return redirect_to root_path, notice: tp("not_found") unless @quiz.present?

        redirect_to root_path, alert: t("errors.not_allowed_to_view_quiz") unless @quiz.user_allowed_to_view? @user
    end

    def request_destroy
        @quiz = Quiz.find_by(uuid: params[:quiz_uuid])

        # TODO: Fix this shit with JWT
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
        4.times { @quiz.translations.build } unless @quiz.translations.count.positive?

        return if @quiz.present?

        redirect_to root_path, notice: tp("not_found")
    end

    def update
        override_action "new"

        @quiz = @user.quizzes.find_by(uuid: params[:quiz_uuid])

        redirect_to root_path, notice: tp("not_found") unless @quiz.present?

        if @quiz.update(quiz_params)
            redirect_to quiz_show_path(@quiz.uuid), notice: tp("saved")
        else
            flash.now.alert = @quiz.get_errors
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        quiz = @user.quizzes.find_by(uuid: params[:quiz_uuid])
        token = params[:destroy_token]

        redirect_to root_path, notice: tp("not_found") unless quiz.present?

        if quiz.user == @user && quiz.compare_encrypted(:destroy_token, token) &&
           quiz.destroy_expire > Time.now
            quiz.destroy
            flash.notice = tp("deleted")
        else
            flash.alert = tp("not_allowed")
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
            translations_attributes: %i[id word translation _destroy]
        )
    end

    def require_beta!
        return unless require_login!

        render "errors/beta_wall" unless @user.beta? || @user.admin?
    end
end
