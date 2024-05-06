class SwitchFromBinaryToTable < ActiveRecord::Migration[7.1]
  def change
    remove_column :quizzes, :data

    if table_exists? :scores
      drop_table :scores
    end
  end
end
