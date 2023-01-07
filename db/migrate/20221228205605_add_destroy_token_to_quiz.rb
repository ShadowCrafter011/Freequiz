class AddDestroyTokenToQuiz < ActiveRecord::Migration[7.0]
  def change
    add_column :quizzes, :destroy_token, :string
    add_column :quizzes, :destroy_expire, :datetime
  end
end
