class AddDefaultToSettingLocale < ActiveRecord::Migration[7.0]
    def change
        change_column_default :settings, :locale, "de"
    end
end
