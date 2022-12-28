class Quiz::QuizController < ApplicationController
  before_action :require_beta! do
    setup_locale "quiz.quiz"
  end

  def new
    @quiz = current_user.quizzes.new
  end

  def create
    override_action :new
    
    @quiz = current_user.quizzes.new(quiz_params)
    if @quiz.save
      gn s: tp("quiz_created")
      redirect_to quiz_show_path(@quiz)
    else
      gn a: @quiz.get_errors
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @quiz = Quiz.find_by(id: params[:id])
    
    unless @quiz.present?
      gn n: tp("not_found")
      redirect_to root_path
    end
  end

  def update
  end

  private
  def quiz_params
    params.require(:quiz).permit(:title, :description, :from, :to, :visibility, data: [:w, :t])
  end

  def require_beta!
    return unless require_login!
    render "errors/beta_wall" unless @user.beta? || @user.admin?
  end
end
