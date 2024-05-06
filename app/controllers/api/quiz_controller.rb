class Api::QuizController < ApplicationController
    include ApiUtils

    protect_from_forgery with: :null_session
    before_action :api_require_valid_bearer_token!,
                  except: %i[data score reset_score favorite]
    around_action :locale_en
    skip_before_action :setup_login
    skip_around_action :switch_locale

    before_action :api_require_valid_access_token!, except: %i[data search]

    def search
        query = ActiveRecord::Base.connection.quote(params[:query])
        page = params[:page] || 1
        offset = (page.to_i * 50) - 50
        @quizzes =
            Quiz.find_by_sql(
                "SELECT * FROM quizzes WHERE visibility = 'public' ORDER BY SIMILARITY(title, #{query}) DESC LIMIT 50 OFFSET #{offset}"
            )

        render "api/user/quizzes"
    end

    def create
        unless validate_params(
            :title,
            :description,
            :from,
            :to,
            :visibility,
            hash: quiz_params
        )
            return(
                json(
                    {
                        success: false,
                        token: "fields.missing",
                        message: "Missing title, description, from, to or visibility"
                    },
                    :bad_request
                )
            )
        end

        @quiz = @api_user.quizzes.new(quiz_params)

        unless @quiz.valid?
            return(
                json(
                    {
                        success: false,
                        token: "record.invalid",
                        errors: @quiz.errors.details,
                        message: "Some parameters don't meet requirements"
                    },
                    :bad_request
                )
            )
        end

        unless @quiz.data.length.positive?
            return(
                json(
                    {
                        success: false,
                        token: "translations.notenough",
                        message: "Not enough translations"
                    },
                    :bad_request
                )
            )
        end

        unless @quiz.save
            return(
                json(
                    {
                        success: false,
                        token: "record.invalid",
                        errors: @quiz.errors.details,
                        message: "Something went wrong whilst creating the quiz"
                    },
                    :unprocessable_entity
                )
            )
        end

        render nothing: true, status: :created
    end

    def data
        unless (@quiz = Quiz.find_by(uuid: params[:quiz_id])).present?
            return(
                json(
                    {
                        success: false,
                        token: "quiz.notfound",
                        message: "Quiz doesn't exist"
                    },
                    :not_found
                )
            )
        end
        return if @quiz.user_allowed_to_view? api_current_user

        json(
            {
                success: false,
                token: "user.notallowed",
                message: "User is not allowed to view Quiz"
            },
            :unauthorized
        )
    end

    def request_destroy
        unless (quiz = Quiz.find_by(uuid: params[:quiz_id])).present?
            return(
                json(
                    {
                        success: false,
                        token: "quiz.notfound",
                        message: "Quiz doesn't exist"
                    },
                    :not_found
                )
            )
        end
        unless quiz.user == @api_user
            return(
                json(
                    {
                        success: false,
                        token: "user.notallowed",
                        message: "User is not allowed to manage this Quiz"
                    },
                    :unauthorized
                )
            )
        end

        token = SecureRandom.hex(32)
        expire = 1.day.from_now
        quiz.update(destroy_token: token, destroy_expire: expire)
        quiz.encrypt_value :destroy_token

        json({ success: true, token:, expire: expire.to_i })
    end

    def destroy
        unless (quiz = Quiz.find_by(uuid: params[:quiz_id])).present?
            return(
                json(
                    {
                        success: false,
                        token: "quiz.notfound",
                        message: "Quiz doesn't exist"
                    },
                    :not_found
                )
            )
        end
        unless quiz.user == @api_user
            return(
                json(
                    {
                        success: false,
                        token: "user.notallowed",
                        message: "User is not allowed to manage this Quiz"
                    },
                    :unauthorized
                )
            )
        end
        unless quiz.destroy_expire > Time.now
            return(
                json(
                    { success: false, token: "token.expired", message: "Token expired" },
                    :unauthorized
                )
            )
        end
        unless quiz.compare_encrypted :destroy_token, params[:destroy_token]
            return(
                json(
                    {
                        success: false,
                        token: "token.invalid",
                        message: "Token is invalid"
                    },
                    :unauthorized
                )
            )
        end

        quiz.destroy
        json({ success: true, message: "Quiz deleted" })
    end

    def update
        unless (@quiz = @api_user.quizzes.find_by(uuid: params[:quiz_id])).present?
            return(
                json(
                    {
                        success: false,
                        tokne: "quiz.notfound",
                        message: "Quiz doesn't exist or is not owned by user"
                    },
                    :not_found
                )
            )
        end

        unless @quiz.update(quiz_params)
            return(
                json(
                    {
                        success: false,
                        token: "record.invalid",
                        errors: @quiz.errors.details,
                        message: "Something went wrong whilst saving the Quiz"
                    },
                    :bad_request
                )
            )
        end

        render nothing: true, status: :accepted
    end

    def score
        unless (quiz = Quiz.find_by(uuid: params[:quiz_id])).present?
            return(
                json(
                    {
                        success: false,
                        token: "quiz.notfound",
                        message: "Quiz doesn't exist"
                    },
                    :not_found
                )
            )
        end
        unless params[:score].present?
            return(
                json(
                    { success: false, token: "fields.missing", message: "Missing score" },
                    :bad_request
                )
            )
        end
        score_data = params[:score]

        score = @api_user.scores.find_by(quiz_id: quiz.uuid)
        update_score score, score_data.to_unsafe_h
        json({ success: true, message: "Score updated" }, :accepted)
    end

    def reset_score
        unless (quiz = Quiz.find_by(uuid: params[:quiz_id])).present?
            return(
                json(
                    {
                        success: false,
                        token: "quiz.notfound",
                        message: "Quiz doesn't exist"
                    },
                    :not_found
                )
            )
        end

        score = @api_user.scores.find_by(quiz_id: quiz.uuid)
        index = Score::MODES.values.index(params[:mode])

        score.data.each_value do |val|
            score.total += val[index]
            val[index] = 0
        end
        score.save
        json(
            {
                success: true,
                message: "Score was reset for mode #{params[:mode].downcase}"
            },
            :accepted
        )
    end

    def favorite
        unless (quiz = Quiz.find_by(uuid: params[:quiz_id])).present?
            return(
                json(
                    {
                        success: false,
                        token: "quiz.notfound",
                        message: "Quiz doesn't exist"
                    },
                    :not_found
                )
            )
        end

        score = @api_user.scores.find_by(quiz_id: quiz.uuid)
        if favorite_params.key? :add
            filtered =
                favorite_params[:add].select { |hash| score.data.key?(hash.to_sym) }
            score.favorites.concat(filtered)
        end
        if favorite_params.key? :remove
            favorite_params[:remove].each do |hash|
                score.favorites.delete(hash)
            end
        end
        score.save
        json({ success: true, message: "Favorites updated" }, :accepted)
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

    def favorite_params
        params.require(:favorites).permit(add: [], remove: [])
    end

    def update_score(score, data)
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
