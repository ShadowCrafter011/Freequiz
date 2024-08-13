class Admin::QuizController < ApplicationController
    around_action :locale_en

    def edit
        @quiz = Quiz.find_by(uuid: params[:quiz_id])
    end

    def update
        @quiz = Quiz.find_by(uuid: params[:quiz_id])

        redirect_to root_path, notice: "Quiz was not found" unless @quiz.present?

        if @quiz.update(quiz_params)
            redirect_to quiz_show_path(@quiz.uuid), notice: "Quiz updated as admin"
        else
            flash.now.alert = @quiz.get_errors
            render :edit, status: :unprocessable_entity
        end
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
end
