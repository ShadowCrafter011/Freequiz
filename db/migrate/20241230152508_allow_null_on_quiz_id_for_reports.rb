class AllowNullOnQuizIdForReports < ActiveRecord::Migration[7.1]
  def change
    change_column_null :quiz_reports, :quiz_id, true
  end
end
