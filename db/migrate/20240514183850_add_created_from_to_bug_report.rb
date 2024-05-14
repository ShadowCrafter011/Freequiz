class AddCreatedFromToBugReport < ActiveRecord::Migration[7.1]
  def change
    add_column :bug_reports, :created_from, :string
    add_column :bug_reports, :steps, :text
    add_column :bug_reports, :ip, :string
    add_column :bug_reports, :request_method, :string
    add_column :bug_reports, :media_type, :string
    add_column :bug_reports, :post_parameters, :string
  end
end
