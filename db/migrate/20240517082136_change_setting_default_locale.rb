class ChangeSettingDefaultLocale < ActiveRecord::Migration[7.1]
  def change
    change_column_default :settings, :locale, "en"
  end
end
