class AddFavoritesToScore < ActiveRecord::Migration[7.0]
    def change
        add_column :scores, :favorites, :binary
    end
end
