class CreateQuizReports < ActiveRecord::Migration[7.1]
  def change
    create_table :quiz_reports do |t|
      t.string :status, default: "open"
      t.text :description
      t.boolean :sexual
      t.boolean :violence
      t.boolean :hate
      t.boolean :spam
      t.boolean :child_abuse
      t.boolean :mobbing
      t.references :quiz, null: false, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
