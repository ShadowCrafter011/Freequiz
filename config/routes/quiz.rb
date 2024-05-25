namespace :quiz do
    get "create", to: "quiz#new", as: "create"
    post "create", to: "quiz#create"

    scope ":quiz_uuid" do
        get "/", to: "quiz#show", as: "show"
        get "edit", to: "quiz#edit", as: "edit"
        patch "edit", to: "quiz#update"
        get "delete", to: "quiz#request_destroy", as: "request_destroy"
        delete "delete/:destroy_token", to: "quiz#destroy", as: "delete"

        patch "favorite", to: "quiz#favorite", as: "favorite"

        get "cards", to: "quiz#cards", as: "cards"
        get "write", to: "quiz#write", as: "write"
        get "multi", to: "quiz#multi", as: "multi"
        get "smart", to: "quiz#smart", as: "smart"
    end
end
