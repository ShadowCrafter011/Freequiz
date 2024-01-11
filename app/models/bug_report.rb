class BugReport < ApplicationRecord
    belongs_to :user, optional: true

    STATUSES = %w[new open solved closed duplicate].freeze

    validates :title, length: { minimum: 3, maximum: 255 }
    validates :body, length: { minimum: 10, maximum: 30_000 }

    before_validation { self.status ||= "new" }
end
