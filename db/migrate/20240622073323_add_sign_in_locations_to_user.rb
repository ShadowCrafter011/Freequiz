class AddSignInLocationsToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :current_sign_in_location, :string
    add_column :users, :last_sign_in_location, :string
  end
end
