class AddUrlToBugReport < ActiveRecord::Migration[7.0]
  def change
    add_column :bug_reports, :url, :string
  end
end
