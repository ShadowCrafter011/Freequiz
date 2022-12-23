class Quiz < ApplicationRecord
  # Quizzes can store up to 5000 translations with 255 characters each

  belongs_to :user

  VISIBILITIES = ["public", "private", "hidden"]

  validates :title, presence: true, length: { minimum: 5, maximum: 255 }
  validates :description, presence: true, length: { minimum: 10, maximum: 30000 }
  validates :visibility, inclusion: { in: VISIBILITIES }

  validate :validate_langs
  validate :translation_length

  attribute :data, :binary_hash

  before_create do
    self.uuid = SecureRandom.hex(4)
    while Quiz.exists? uuid: self.uuid do
      self.uuid = SecureRandom.hex(4)
    end
  end

  private
  def validate_langs
    errors.add(:from, "is not a supported language") unless Language.exists?(self.from)
    errors.add(:to, "is not a supported language") unless Language.exists?(self.to)
  end

  def translation_length
    errors.add(:data, "must have at least one translation") unless self.data[:translations].length > 0
  end
end
