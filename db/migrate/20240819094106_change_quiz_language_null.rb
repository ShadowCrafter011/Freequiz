class ChangeQuizLanguageNull < ActiveRecord::Migration[7.1]
  def change
    change_column_null :quizzes, :from, false
    change_column_null :quizzes, :to, false
  end
end
