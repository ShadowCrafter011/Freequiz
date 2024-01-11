class AddRemovedToTransaction < ActiveRecord::Migration[7.0]
    def change
        add_column :transactions, :removed, :boolean
    end
end
