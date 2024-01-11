class AddBugSmashedToUser < ActiveRecord::Migration[7.0]
    def change
        add_column :users, :bugs_smashed, :integer
    end
end
