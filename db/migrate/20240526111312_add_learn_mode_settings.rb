class AddLearnModeSettings < ActiveRecord::Migration[7.1]
  def change
    remove_column :settings, :show_email, :boolean
    change_column_default :settings, :dark_mode, from: nil, to: true
    add_column :settings, :write_amount, :integer, default: 2
    add_column :settings, :cards_amount, :integer, default: 2
    add_column :settings, :multi_amount, :integer, default: 2
  end
end
