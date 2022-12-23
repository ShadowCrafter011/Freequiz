class Quiz::QuizController < ApplicationController
  before_action :require_login!, :require_beta!

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
    render "errors/beta_wall" unless @user.beta? || @user.admin?
  end
end
