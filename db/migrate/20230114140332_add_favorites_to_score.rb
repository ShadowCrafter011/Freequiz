class AddFavoritesToScore < ActiveRecord::Migration[7.0]
    def change
	if table_exists? :scores
            add_column :scores, :favorites, :binary
	end
    end
end
