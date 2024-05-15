post "report", to: "bug_report#create", as: "bug_report"

scope :bugs do
    scope :triage do
        get "/", to: "bug_report#triage", as: "bug_triage"
        get ":bug_report_id", to: "bug_report#triage_show", as: "bug_triage_show"
        patch ":bug_report_id", to: "bug_report#triage_verdict"
    end

    get "list", to: "bug_report#list", as: "bugs"

    scope ":bug_id" do
        get "/", to: "bug_report#show", as: "bug"
        patch "status", to: "bug_report#status", as: "bug_status"
    end
end
