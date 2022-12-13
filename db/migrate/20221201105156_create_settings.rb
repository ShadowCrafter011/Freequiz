class CreateSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :settings do |t|
      t.boolean :dark_mode
      t.boolean :show_email
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
