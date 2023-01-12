post "report", to: "bug_report#create", as: "bug_report"

scope :bugs do
    get "/", to: "bug_reports#list", as: "bugs"

    scope ":bug_id" do
        get "/", to: "bug_reports#show", as: "bug"
        get "edit", to: "bug_report#edit", as: "bug_edit"
        patch "edit", to: "bug_report#update"

        patch "status", to: "bug_report#status", as: "bug_status"
    end
end