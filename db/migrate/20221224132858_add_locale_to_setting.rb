class AddLocaleToSetting < ActiveRecord::Migration[7.0]
    def change
        add_column :settings, :locale, :string
    end
end
