class Transaction < ApplicationRecord
  belongs_to :user

  validates :amount, presence: true
  validates :description, presence: true

  before_create do
    self.removed = false
  end

  def self.total
    total = 0
    for transaction in Transaction.where(removed: false) do
      total += transaction.amount
    end
    return total
  end
end
