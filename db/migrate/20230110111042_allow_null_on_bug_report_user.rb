class AllowNullOnBugReportUser < ActiveRecord::Migration[7.0]
  def change
    change_column_null :bug_reports, :user_id, true
  end
end
