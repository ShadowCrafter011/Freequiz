class Transaction < ApplicationRecord
  belongs_to :user, optional: true

  validates :amount, presence: true
  validates :description, presence: true

  def self.total
    total = 0
    for transaction in Transaction.where(removed: false) do
      total += transaction.amount
    end
    return total
  end
end
