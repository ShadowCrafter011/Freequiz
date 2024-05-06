class RemoveDestroyTokenFromQuiz < ActiveRecord::Migration[7.1]
  def change
    remove_column :quizzes, :destroy_token
    remove_column :quizzes, :destroy_expire
  end
end
