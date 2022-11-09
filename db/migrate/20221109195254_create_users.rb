class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :username
      t.string :password_digest
      t.string :role
      t.boolean :agb
      t.string :confirmation_token
      t.datetime :confirmation_expire
      t.string :unconfirmed_email
      t.datetime :confirmed_at
      t.string :password_reset_token
      t.datetime :password_reset_expire
      t.integer :sign_in_count
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :password_reset_token, unique: true
    add_index :users, :confirmation_token, unique: true
    add_index :users, :username, unique: true
  end
end
