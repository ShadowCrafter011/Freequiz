class ChangeBugReportStatusDefault < ActiveRecord::Migration[7.1]
  def change
    change_column_default :bug_reports, :status, from: nil, to: "new"
  end
end
