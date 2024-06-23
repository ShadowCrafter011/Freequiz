class CreateBannedIps < ActiveRecord::Migration[7.1]
  def change
    create_table :banned_ips do |t|
      t.string :ip

      t.timestamps
    end
  end
end
