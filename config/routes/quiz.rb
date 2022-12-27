namespace :quiz do
    get "create", to: "quiz#new", as: "create"
    post "create", to: "quiz#create"

    get ":uuid/show", to: "quiz#show", as: "show"
end