class AddForeignKeyToQuizzesLanguages < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :quizzes, :languages, column: :from
    add_foreign_key :quizzes, :languages, column: :to
  end
end
