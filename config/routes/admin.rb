namespace :admin do
    get "users", to: "users#index", as: "users"
    get "user/edit/:username", to: "users#edit", as: "user_edit"
end