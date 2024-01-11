class Transaction < ApplicationRecord
    belongs_to :user, optional: true

    validates :amount, presence: true
    validates :description, presence: true

    def self.total
        total = 0
        Transaction.where(removed: false).each do |transaction|
            total += transaction.amount
        end
        total
    end
end
