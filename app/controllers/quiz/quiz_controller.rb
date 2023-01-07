class Quiz::QuizController < ApplicationController
  include QuizUtils
  
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
    @quiz = Quiz.find_by(id: params[:quiz_id])
    
    return unless check_viewing_privilege

    unless @quiz.present?
      gn n: tp("not_found")
      redirect_to root_path
    end
  end

  def request_destroy
    @quiz = Quiz.find_by(id: params[:quiz_id])

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

    @quiz = @user.quizzes.find_by(id: params[:quiz_id])

    unless @quiz.present?
      gn n: tp("not_found")
      redirect_to root_path
    end
  end

  def update
    override_action "new"

    @quiz = @user.quizzes.find_by(id: params[:quiz_id])

    unless @quiz.present?
      gn n: tp("not_found")
      redirect_to root_path
    end

    if @quiz.update(quiz_params)
      gn s: tp("saved")
      redirect_to quiz_show_path(@quiz)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    quiz = @user.quizzes.find_by(id: params[:quiz_id])
    token = params[:destroy_token]

    unless quiz.present?
      gn n: tp("not_found")
      redirect_to root_path
    end

    if quiz.compare_encrypted(:destroy_token, token) && quiz.destroy_expire > Time.now
      quiz.destroy
      gn n: tp("deleted")
      redirect_to root_path
    else
      gn a: tp("not_allowed")
      redirect_to root_path
    end
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
