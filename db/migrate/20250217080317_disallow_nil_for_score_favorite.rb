class DisallowNilForScoreFavorite < ActiveRecord::Migration[7.1]
  def change
    change_column_null :scores, :favorite, false
  end
end
