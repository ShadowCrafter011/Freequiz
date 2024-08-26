class AddUniqueIndexToBlockedUserDatum < ActiveRecord::Migration[7.1]
  def change
    add_index :blocked_user_data, :username, unique: true
    add_index :blocked_user_data, :hashed_username, unique: true
    add_index :blocked_user_data, :hashed_email, unique: true
  end
end
