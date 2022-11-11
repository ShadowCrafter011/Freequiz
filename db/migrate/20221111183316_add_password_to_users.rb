class AddPasswordToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :password, :string
    remove_column :users, :password_digest
  end
end
