class DisallowNullOnScoreUserId < ActiveRecord::Migration[7.1]
  def change
    change_column_null :scores, :user_id, false
  end
end
