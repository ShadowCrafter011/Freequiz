class AllowNullUserOnTransactions < ActiveRecord::Migration[7.0]
    def change
        change_column_null :transactions, :user_id, true
    end
end
