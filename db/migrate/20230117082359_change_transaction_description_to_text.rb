class ChangeTransactionDescriptionToText < ActiveRecord::Migration[7.0]
  def change
    change_column :transactions, :description, :text
  end
end
