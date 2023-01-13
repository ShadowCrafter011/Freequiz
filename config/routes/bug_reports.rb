post "report", to: "bug_report#create", as: "bug_report"

scope :bugs do
    get "/", to: "bug_report#list", as: "bugs"

    scope ":bug_id" do
        get "/", to: "bug_report#show", as: "bug"
        patch "status", to: "bug_report#status", as: "bug_status"
    end
end