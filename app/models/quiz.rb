class Quiz < ApplicationRecord
  # Quizzes can store up to 5000 translations with 255 characters each

  belongs_to :user, optional: true
  has_many :scores, dependent: :destroy

  VISIBILITIES = ["public", "private", "hidden"]

  validates :title, length: { minimum: 3, maximum: 255 }
  validates :description, length: { minimum: 5, maximum: 30000 }
  validates :visibility, inclusion: { in: VISIBILITIES }

  validate :validate_langs, :translation_length

  attribute :data, :binary_hash

  before_save do
    hashes = []
    for translation in self.data do
      hash = Digest::SHA256.hexdigest(translation.values.join)[0..5]
      hashes.append(hash)
      translation[:hash] = hash

      translation[:w] = translation[:w].gsub("'", "").gsub("\"", "")
      translation[:t] = translation[:t].gsub("'", "").gsub("\"", "")
    end

    for score in self.scores do
      for hash in hashes do
        score.data[hash] ||= Array.new(Score::MODES.length, 0)
      end
      score.save
    end
  end

  before_validation do
    for translation in self.data do
      self.data.delete(translation) unless translation[:w].present? || translation[:t].present?
    end
  end

  before_create do
    id_char_num = 5
    self.uuid = SecureRandom.base58(id_char_num)
    while Quiz.exists? self.uuid do
      id_char_num += 1
      self.uuid = SecureRandom.base58(id_char_num)
    end

    for translation in self.data do
      self.data.delete(translation) unless translation[:w].present? || translation[:t].present?

      translation[:w] = "N/D" unless translation[:w].present?
      translation[:t] = "N/D" unless translation[:t].present?
    end
  end

  def learn_data user
    score = user.scores.find_by(quiz_id: self.id) || user.scores.create(quiz_id: self.id) if user.present?

    c_data = self.data.clone
    for d in c_data do
      score_data = user.present? ? score.get_data(d[:hash]) : Score.empty
      d[:favorite] = score_data[:favorite]
      d[:score] = score_data[:score]
    end
  end

  def user_allowed_to_view? user
    return (self.visibility == "public" || self.visibility == "hidden") unless user.present?
    self.visibility == "public" || self.visibility == "hidden" || self.user == user || user.admin?
  end

  def encrypt_value key
    for _ in 0..8 do
        self[key] = Digest::SHA256.hexdigest self[key]
    end
    self.save
  end

  def compare_encrypted key, value
    for _ in 0..8 do
        value = Digest::SHA256.hexdigest value
    end
    self[key] == value
  end

  def get_errors
    self.errors.full_messages
  end

  private
  def validate_langs
    errors.add(:from, I18n.t("errors.invalid_lang")) unless Language.exists?(self.from)
    errors.add(:to, I18n.t("errors.invalid_lang")) unless Language.exists?(self.to)
  end

  def translation_length
    for translation in self.data do
      return if translation[:w].present? && translation[:t].present?
    end
    errors.add(:data, I18n.t("errors.not_enough_translations"))
  end
end
