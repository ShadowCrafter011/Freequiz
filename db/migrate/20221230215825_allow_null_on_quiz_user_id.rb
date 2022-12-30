class AllowNullOnQuizUserId < ActiveRecord::Migration[7.0]
  def change
    change_column_null :quizzes, :user_id, true
  end
end
