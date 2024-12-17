require "test_helper"

class TransactionTest < ActiveSupport::TestCase
    test "removed default" do
        transaction = Transaction.create amount: 1, description: "Rails Test"
        assert_equal 1, transaction.amount
        assert_equal "Rails Test", transaction.description
    end

    test "total value" do
        Transaction.destroy_all
        total = 0
        10.times do
            value = rand(-10..10)
            total += value
            Transaction.create amount: value, description: "Test one two three"
        end
        assert_equal total, Transaction.total
    end
end
