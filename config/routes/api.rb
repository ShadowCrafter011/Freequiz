namespace :api do
    scope :v1 do
        scope :user do
            defaults format: :json do
                put "create", to: "user#create"
                post "login", to: "user#login"
                post "refresh", to: "user#refresh_token"

                get "delete_token", to: "user#request_delete_token"
                delete "delete/:destroy_token", to: "user#destroy"

                patch "update", to: "user#update"
                patch "settings", to: "user#update_settings"

                get "data", to: "user#data"
            end
        end

        scope :docs do
            get "/", to: "docs#index", as: "docs"
            get "users", to: "docs#users", as: "docs_users"
            get "authentication", to: "docs#authentication", as: "docs_authentication"
        end
    end
end