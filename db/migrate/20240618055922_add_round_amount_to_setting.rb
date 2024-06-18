class AddRoundAmountToSetting < ActiveRecord::Migration[7.1]
  def change
    add_column :settings, :round_amount, :integer, default: 10
  end
end
