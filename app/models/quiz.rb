class Quiz < ApplicationRecord
    # Quizzes can store up to 5000 translations with 255 characters each

    belongs_to :user, optional: true
    has_many :scores, dependent: :destroy

    VISIBILITIES = %w[public private hidden].freeze

    validates :title, length: { minimum: 3, maximum: 255 }
    validates :description, length: { minimum: 5, maximum: 30_000 }
    validates :visibility, inclusion: { in: VISIBILITIES }

    validate :validate_langs, :translation_length

    attribute :data, :binary_hash

    before_save do
        hashes = []
        data.each do |translation|
            hash = Digest::SHA256.hexdigest(translation.values.join)[0..5]
            hashes.append(hash)
            translation[:hash] = hash

            translation[:w] = translation[:w].gsub("'", "").gsub("\"", "")
            translation[:t] = translation[:t].gsub("'", "").gsub("\"", "")
        end

        scores.each do |score|
            hashes.each do |hash|
                score.data[hash] ||= Array.new(Score::MODES.length, 0)
            end
            score.save
        end
    end

    before_validation do
        data.each do |translation|
            data.delete(translation) unless translation[:w].present? || translation[:t].present?
        end
    end

    before_create do
        id_char_num = 5
        self.uuid = SecureRandom.base58(id_char_num)
        while Quiz.exists? uuid
            id_char_num += 1
            self.uuid = SecureRandom.base58(id_char_num)
        end

        data.each do |translation|
            data.delete(translation) unless translation[:w].present? || translation[:t].present?

            translation[:w] = "N/D" unless translation[:w].present?
            translation[:t] = "N/D" unless translation[:t].present?
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

    def translation_length
        data.each do |translation|
            return true if translation[:w].present? && translation[:t].present?
        end
        errors.add(:data, I18n.t("errors.not_enough_translations"))
    end
end
