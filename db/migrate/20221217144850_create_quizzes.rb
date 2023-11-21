class CreateQuizzes < ActiveRecord::Migration[7.0]
  def change
    create_table :quizzes, id: :uuid do |t|
      t.string :uuid, null: false
      t.string :name
      t.text :description
      t.string :from
      t.string :to
      t.string :visibility
      t.references :user, null: false, foreign_key: true

      t.timestamps

      t.index :uuid, unique: true
    end
  end
end
