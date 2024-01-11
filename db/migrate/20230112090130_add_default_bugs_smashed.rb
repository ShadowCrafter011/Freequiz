class AddDefaultBugsSmashed < ActiveRecord::Migration[7.0]
    def change
        change_column_default :users, :bugs_smashed, 0
    end
end
