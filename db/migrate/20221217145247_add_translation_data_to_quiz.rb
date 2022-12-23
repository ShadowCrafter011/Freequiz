class AddTranslationDataToQuiz < ActiveRecord::Migration[7.0]
  def change
    add_column :quizzes, :data, :binary
  end
end
