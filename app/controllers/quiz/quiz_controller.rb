class Quiz::QuizController < ApplicationController
  before_action :require_beta! do
    setup_locale "quiz.quiz"
  end

  def new
    @quiz = Quiz.new
  end

  def create
  end

  def show
  end

  def update
  end

  private
  def require_beta!
    return unless require_login!
    render "errors/beta_wall" unless @user.beta? || @user.admin?
  end
end
