class Quiz < ApplicationRecord
    belongs_to :user, optional: true
    has_many :translations, dependent: :destroy

    accepts_nested_attributes_for :translations, reject_if: :all_blank, allow_destroy: true

    VISIBILITIES = %w[public private hidden].freeze

    validates :title, length: { minimum: 3, maximum: 255 }
    validates :description, length: { maximum: 30_000 }
    validates :visibility, inclusion: { in: VISIBILITIES }

    validate :validate_langs

    before_create do
        id_char_num = 5
        self.uuid = SecureRandom.base58(id_char_num)
        while Quiz.exists? uuid
            id_char_num += 1
            self.uuid = SecureRandom.base58(id_char_num)
        end
    end

    def self.search_quizzes(quiz_collection, params)
        title = ActiveRecord::Base.connection.quote_string params[:title] if params[:title].present?
        quizzes = if params[:title]
                      quiz_collection.order(Arel.sql("SIMILARITY(title, '#{title}') DESC"))
                  else
                      quiz_collection
                  end

        quizzes = case params[:sort]
                  when "oldest"
                      quizzes.order(created_at: :asc)
                  when "most_translations"
                      quizzes.order(translations_count: :desc)
                  when "least_translations"
                      quizzes.order(translations_count: :asc)
                  else
                      quizzes.order(created_at: :desc)
                  end

        pages = quiz_collection.count.fdiv(50).ceil
        quizzes = quizzes.limit(50).offset(((params[:page] || 1).to_i - 1) * 50)
        [quizzes, pages]
    end

    def self.search_all_quizzes(params)
        Quiz.search_quizzes(Quiz.where(visibility: "public"), params)
    end

    def self.search_user_quizzes(user, params)
        Quiz.search_quizzes(user.quizzes, params)
    end

    def learn_data(user)
        if user.present?
            translations.each do |translation|
                next if user.scores.exists? translation_id: translation.id

                user.scores.create translation_id: translation.id
            end

            user.scores.joins(:translation).where("translation.quiz_id": id).map do |score|
                translation = score.translation
                {
                    score_id: score.id,
                    word: translation.word,
                    translation: translation.translation,
                    favorite: score.favorite,
                    score: {
                        smart: score.smart,
                        write: score.write,
                        multi: score.multi,
                        cards: score.cards
                    }
                }
            end
        else
            translations.map { |t| { word: t.word, translation: t.translation } }
        end
    end

    def user_allowed_to_view?(user)
        return(visibility == "public" || visibility == "hidden") unless user.present?

        visibility == "public" || visibility == "hidden" ||
            self.user == user || user.admin?
    end

    def get_errors
        errors.full_messages
    end

    private

    def validate_langs
        errors.add(:from, I18n.t("errors.invalid_lang")) unless Language.exists?(from)
        return if Language.exists?(to)

        errors.add(:to, I18n.t("errors.invalid_lang"))
    end
end
