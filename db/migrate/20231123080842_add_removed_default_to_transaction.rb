class AddRemovedDefaultToTransaction < ActiveRecord::Migration[7.0]
    def change
        change_column_default :transactions, :removed, to: false, from: nil
    end
end
