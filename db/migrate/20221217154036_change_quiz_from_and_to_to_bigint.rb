class ChangeQuizFromAndToToBigint < ActiveRecord::Migration[7.0]
  def change
    remove_column :quizzes, :from
    remove_column :quizzes, :to
    add_column :quizzes, :from, :bigint
    add_column :quizzes, :to, :bigint
  end
end
