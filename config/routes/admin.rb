namespace :admin do
    get "users", to: "users#index", as: "users"
    get "users/edit/:username", to: "users#edit", as: "user_edit"
end