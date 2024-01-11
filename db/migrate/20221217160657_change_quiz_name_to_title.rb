class ChangeQuizNameToTitle < ActiveRecord::Migration[7.0]
    def change
        remove_column :quizzes, :name
        add_column :quizzes, :title, :string
    end
end
