class RemoveBugsSmashedFromUser < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :bugs_smashed, :string
  end
end
