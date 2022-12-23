class CreateQuizzes < ActiveRecord::Migration[7.0]
  def change
    create_table :quizzes do |t|
      t.string :name
      t.text :description
      t.string :from
      t.string :to
      t.string :visibility
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
