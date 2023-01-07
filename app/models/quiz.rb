class Quiz < ApplicationRecord
  # Quizzes can store up to 5000 translations with 255 characters each

  belongs_to :user, optional: true

  VISIBILITIES = ["public", "private", "hidden"]

  validates :title, length: { minimum: 3, maximum: 255 }
  validates :description, length: { minimum: 5, maximum: 30000 }
  validates :visibility, inclusion: { in: VISIBILITIES }

  validate :validate_langs, :translation_length

  attribute :data, :binary_hash

  before_validation do
    for translation in self.data do
      self.data.delete(translation) unless translation[:w].present? || translation[:t].present?
    end
  end

  before_create do
    id_char_num = 5
    self.id = SecureRandom.base58(id_char_num)
    while Quiz.exists? self.id do
      id_char_num += 1
      self.id = SecureRandom.base58(id_char_num)
    end

    for translation in self.data do
      self.data.delete(translation) unless translation[:w].present? || translation[:t].present?

      translation[:w] = "N/D" unless translation[:w].present?
      translation[:t] = "N/D" unless translation[:t].present?
    end
  end

  def user_allowed_to_view? user
    self.visibility == "public" || self.visibility == "hidden" || self.user == user || user.admin?
  end

  def encrypt_value key
    for x in 0..8 do
        self[key] = Digest::SHA256.hexdigest self[key]
    end
    self.save
  end

  def compare_encrypted key, value
    for x in 0..8 do
        value = Digest::SHA256.hexdigest value
    end
    self[key] == value
  end

  def get_errors
    errors = []
    for x in self.errors.objects do
        errors.append x.full_message
    end
    return errors
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
