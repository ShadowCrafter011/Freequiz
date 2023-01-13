class BugReport < ApplicationRecord
  belongs_to :user, optional: true

  STATUSES = ["new", "open", "solved", "closed", "duplicate"]

  validates :title, length: { minimum: 3, maximum: 255 }
  validates :body, length: { minimum: 10, maximum: 30000 }

  before_validation do
    self.status = "new"
  end
end
