namespace :quiz do
    get "create", to: "quiz#new", as: "create"
    post "create", to: "quiz#create"

    scope ":quiz_id" do
        get "/", to: "quiz#show", as: "show"
        get "edit", to: "quiz#edit", as: "edit"
        patch "edit", to: "quiz#update"
        get "delete", to: "quiz#request_destroy", as: "request_destroy"
        delete "delete/:destroy_token", to: "quiz#destroy", as: "delete"
    end
end