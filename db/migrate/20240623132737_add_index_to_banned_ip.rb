class AddIndexToBannedIp < ActiveRecord::Migration[7.1]
  def change
    add_index :banned_ips, :ip
  end
end
