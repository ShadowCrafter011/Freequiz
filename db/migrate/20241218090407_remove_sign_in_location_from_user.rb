class RemoveSignInLocationFromUser < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :last_sign_in_location, :string
    remove_column :users, :current_sign_in_location, :string
  end
end