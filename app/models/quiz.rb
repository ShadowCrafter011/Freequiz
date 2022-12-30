class Quiz < ApplicationRecord
  # Quizzes can store up to 5000 translations with 255 characters each

  belongs_to :user, optional: true

  VISIBILITIES = ["public", "private", "hidden"]

  validates :title, length: { minimum: 5, maximum: 255 }
  validates :description, length: { minimum: 10, maximum: 30000 }
  validates :visibility, inclusion: { in: VISIBILITIES }

  validate :validate_langs, :translation_length

  attribute :data, :binary_hash

  before_create do
    self.id = SecureRandom.base58(6)
    while Quiz.exists? self.id do
      self.id = SecureRandom.base58(6)
    end

    for translation in self.data do
      self.data.delete(translation) unless translation[:w].present? || translation[:t].present?

      translation[:w] = "Not defined" unless translation[:w].present?
      translation[:t] = "Not defined" unless translation[:t].present?
    end
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
