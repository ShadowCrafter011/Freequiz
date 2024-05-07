class Quiz < ApplicationRecord
    belongs_to :user, optional: true
    has_many :translations, dependent: :destroy
    has_many :scores, dependent: :destroy

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

    def learn_data(user)
        if user.present?
            score =
                user.scores.find_by(quiz_id: id) ||
                user.scores.create(quiz_id: id)
        end

        c_data = data.clone
        c_data.each do |d|
            score_data = user.present? ? score.get_data(d[:hash]) : Score.empty
            d[:favorite] = score_data[:favorite]
            d[:score] = score_data[:score]
        end
    end

    def user_allowed_to_view?(user)
        return(visibility == "public" || visibility == "hidden") unless user.present?

        visibility == "public" || visibility == "hidden" ||
            self.user == user || user.admin?
    end

    def encrypt_value(key)
        9.times do
            self[key] = Digest::SHA256.hexdigest self[key]
        end
        save
    end

    def compare_encrypted(key, value)
        9.times do
            value = Digest::SHA256.hexdigest value
        end
        self[key] == value
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
