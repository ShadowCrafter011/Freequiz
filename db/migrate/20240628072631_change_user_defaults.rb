class ChangeUserDefaults < ActiveRecord::Migration[7.1]
  def change
    change_column_default :users, :role, "user"
    change_column_default :users, :sign_in_count, 1
    change_column_default :users, :confirmed, false
  end
end
