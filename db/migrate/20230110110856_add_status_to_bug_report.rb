class AddStatusToBugReport < ActiveRecord::Migration[7.0]
  def change
    add_column :bug_reports, :status, :string
  end
end
