class CreateBugReports < ActiveRecord::Migration[7.0]
    def change
        create_table :bug_reports do |t|
            t.string :title
            t.text :body
            t.string :platform
            t.references :user, null: false, foreign_key: true

            t.timestamps
        end
    end
end
