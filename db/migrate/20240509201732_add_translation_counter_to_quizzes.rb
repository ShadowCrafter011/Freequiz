class AddTranslationCounterToQuizzes < ActiveRecord::Migration[7.1]
  def change
    add_column :quizzes, :translations_count, :integer, default: 0
  end
end
