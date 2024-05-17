class ChangeScore < ActiveRecord::Migration[7.1]
  def change
    rename_column :scores, :learn, :smart
    add_column :scores, :multi, :integer
    add_column :scores, :favorite, :boolean, default: false

    change_column_default :scores, :smart, from: nil, to: 0
    change_column_default :scores, :cards, from: nil, to: 0
    change_column_default :scores, :multi, from: nil, to: 0
    change_column_default :scores, :write, from: nil, to: 0

    remove_foreign_key :scores, :quizzes
    remove_column :scores, :quiz_id, :bigint
    add_column :scores, :translation_id, :bigint
    add_foreign_key :scores, :translations
    add_index :scores, :translation_id
  end
end
