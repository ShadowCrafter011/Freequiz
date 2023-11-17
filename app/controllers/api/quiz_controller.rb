class Api::QuizController < ApplicationController
  include ApiUtils

  protect_from_forgery with: :null_session
  before_action :api_require_valid_bearer_token!, except: [:data, :score, :reset_score, :favorite]
  around_action :locale_en
  skip_before_action :setup_login
  skip_around_action :switch_locale

  before_action :api_require_valid_access_token!, except: [:data, :search]

  def search
    query = ActiveRecord::Base.connection.quote(params[:query])
    page = params[:page] || 1
    offset = page.to_i * 50 - 50
    @quizzes = Quiz.find_by_sql("SELECT * FROM quizzes WHERE visibility = 'public' ORDER BY SIMILARITY(title, #{query}) DESC LIMIT 50 OFFSET #{offset}")

    render "api/user/quizzes"
  end

  def create
    return json({success: false, token: "fields.missing", message: "Missing title, description, from, to or visibility"}, :bad_request) unless validate_params(:title, :description, :from, :to, :visibility, hash: quiz_params)

    @quiz = @api_user.quizzes.new(quiz_params)

    # TODO: Add error token
    return json({success: false, token: "record.invalid", errors: @quiz.errors.details, message: "Some parameters don't meet requirements"}, :bad_request) unless @quiz.valid?

    return json({success: false, token: "translations.notenough", message: "Not enough translations"}, :bad_request) unless @quiz.data.length > 0

    # TODO: Add error token
    return json({success: false, token: "record.invalid", errors: @quiz.errors.details, message: "Something went wrong whilst creating the quiz"}, :unprocessable_entity) unless @quiz.save

    render nothing: true, status: :created
  end

  def data
    return json({success: false, token: "quiz.notfound", message: "Quiz doesn't exist"}, :not_found) unless (@quiz = Quiz.find_by(id: params[:quiz_id])).present?
    return json({success: false, token: "user.notallowed", message: "User is not allowed to view Quiz"}, :unauthorized) unless @quiz.user_allowed_to_view? api_current_user
  end

  def request_destroy
    return json({success: false, token: "quiz.notfound", message: "Quiz doesn't exist"}, :not_found) unless (quiz = Quiz.find_by(id: params[:quiz_id])).present?
    return json({success: false, token: "user.notallowed", message: "User is not allowed to manage this Quiz"}, :unauthorized) unless quiz.user == @api_user

    token = SecureRandom.hex(32)
    expire = 1.day.from_now
    quiz.update(destroy_token: token, destroy_expire: expire)
    quiz.encrypt_value :destroy_token

    json({success: true, token: token, expire: expire.to_i})
  end

  def destroy
    return json({success: false, token: "quiz.notfound", message: "Quiz doesn't exist"}, :not_found) unless (quiz = Quiz.find_by(id: params[:quiz_id])).present?
    return json({success: false, token: "user.notallowed", message: "User is not allowed to manage this Quiz"}, :unauthorized) unless quiz.user == @api_user
    return json({success: false, token: "token.expired", message: "Token expired"}, :unauthorized) unless quiz.destroy_expire > Time.now
    return json({success: false, token: "token.invalid", message: "Token is invalid"}, :unauthorized) unless quiz.compare_encrypted :destroy_token, params[:destroy_token]

    quiz.destroy
    json({success: true, message: "Quiz deleted"})
  end

  def update
    return json({success: false, tokne: "quiz.notfound", message: "Quiz doesn't exist or is not owned by user"}, :not_found) unless (@quiz = @api_user.quizzes.find_by(id: params[:quiz_id])).present?

    # TODO: Add error token
    return json({success: false, token: "record.invalid", errors: @quiz.errors.details, message: "Something went wrong whilst saving the Quiz"}, :bad_request) unless @quiz.update(quiz_params)

    render nothing: true, status: :accepted
  end

  def score
    return json({success: false, token: "quiz.notfound", message: "Quiz doesn't exist"}, :not_found) unless (quiz = Quiz.find_by(id: params[:quiz_id])).present?
    return json({success: false, token: "fields.missing", message: "Missing score"}, :bad_request) unless (score_data = params[:score]).present?
    score_data = params[:score]

    score = @api_user.scores.find_by(quiz_id: quiz.id)
    update_score score, score_data.to_unsafe_h
    json({success: true, message: "Score updated"}, :accepted)
  end

  def reset_score
    return json({success: false, token: "quiz.notfound", message: "Quiz doesn't exist"}, :not_found) unless (quiz = Quiz.find_by(id: params[:quiz_id])).present?

    score = @api_user.scores.find_by(quiz_id: quiz.id)
    index = Score::MODES.values.index(params[:mode])

    score.data.values.each do |val|
      score.total += val[index]
      val[index] = 0
    end
    score.save
    json({success: true, message: "Score was reset for mode #{params[:mode].downcase}"}, :accepted)
  end

  def favorite
    return json({success: false, token: "quiz.notfound", message: "Quiz doesn't exist"}, :not_found) unless (quiz = Quiz.find_by(id: params[:quiz_id])).present?
    
    score = @api_user.scores.find_by(quiz_id: quiz.id)
    if favorite_params.has_key? :add
      filtered = favorite_params[:add].select {|hash| score.data.has_key?(hash.to_sym) }
      score.favorites.concat(filtered)
    end
    if favorite_params.has_key? :remove
      for hash in favorite_params[:remove] do
        score.favorites.delete(hash)
      end
    end
    score.save
    json({success: true, message: "Favorites updated"}, :accepted)
  end

  private
  def quiz_params
    params.require(:quiz).permit(:title, :description, :from, :to, :visibility, data: [:w, :t])
  end

  def favorite_params
    params.require(:favorites).permit(add: [], remove: [])
  end

  def update_score score, data
    data.entries.each do |hash, score_data|
      score_data.entries.each do |key, value|
        score_index = Score::MODES.values.index(key.to_s)

        next unless score_index.present? && score.data.include?(hash.to_sym)

        score.data[hash.to_sym][score_index] = value.to_i
      end
    end
    score.save
  end
end
