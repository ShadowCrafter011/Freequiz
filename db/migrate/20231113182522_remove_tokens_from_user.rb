class RemoveTokensFromUser < ActiveRecord::Migration[7.0]
    def change
        remove_column :users, :destroy_token
        remove_column :users, :destroy_expire

        remove_column :users, :confirmation_token
        remove_column :users, :confirmation_expire

        remove_column :users, :password_reset_token
        remove_column :users, :password_reset_expire
    end
end
