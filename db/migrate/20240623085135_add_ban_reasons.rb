class AddBanReasons < ActiveRecord::Migration[7.1]
  def change
    add_column :banned_ips, :reason, :string
    add_column :users, :ban_reason, :string
  end
end
