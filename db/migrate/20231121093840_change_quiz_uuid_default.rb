class ChangeQuizUuidDefault < ActiveRecord::Migration[7.0]
  def change
    change_column_default :quizzes, :id, nil
  end
end
