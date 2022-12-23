namespace :quiz do
    get "create", to: "quiz#new", as: "create_path"
    post "create", to: "quiz#create"
end