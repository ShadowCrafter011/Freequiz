class CreateBlockedUserData < ActiveRecord::Migration[7.1]
  def change
    create_table :blocked_user_data do |t|
      t.string :username
      t.string :hashed_email
      t.string :hashed_username

      t.timestamps
    end
  end
end
