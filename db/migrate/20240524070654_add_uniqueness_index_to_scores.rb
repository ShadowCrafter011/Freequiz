class AddUniquenessIndexToScores < ActiveRecord::Migration[7.1]
  def change
    add_index :scores, [:user_id, :translation_id], unique: true
  end
end
