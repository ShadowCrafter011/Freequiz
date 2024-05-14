class BugReport < ApplicationRecord
    belongs_to :user, optional: true

    STATUSES = %w[new open solved closed duplicate].freeze

    validates :title, length: { maximum: 255 }
    validates :body, length: { maximum: 30_000 }

    before_validation { self.status ||= "new" }
end
