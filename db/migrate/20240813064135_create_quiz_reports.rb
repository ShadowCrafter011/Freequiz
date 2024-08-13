class CreateQuizReports < ActiveRecord::Migration[7.1]
  def change
    create_table :quiz_reports do |t|
      t.string :status, default: "open"
      t.text :description
      t.boolean :sexual, default: false
      t.boolean :violence, default: false
      t.boolean :hate, default: false
      t.boolean :spam, default: false
      t.boolean :child_abuse, default: false
      t.boolean :mobbing, default: false
      t.references :quiz, null: false, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
