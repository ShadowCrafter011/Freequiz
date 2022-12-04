defaults format: :json do
    namespace :api do
        scope :v1 do
            scope :user do
                put "create", to: "user#create"
                post "login", to: "user#login"
                post "refresh_access_token", to: "user#refresh_token"

                get "request_delete_token", to: "user#request_delete_token"
                delete "delete/:destroy_token", to: "user#destroy"

                patch "update", to: "user#update"

                get "data", to: "user#data"
            end
        end
    end
end