namespace :admin do
    get "users", to: "users#index", as: "users"

    get "user"
    
    scope :user do
        scope ":username" do
            get "delete(/:destroy_token)", to: "users#destroy_token", as: "user_delete"
            delete "delete/:destroy_token", to: "users#destroy"
        end

        scope "edit/:username" do
            get "/", to: "users#edit", as: "user_edit"
            patch "/", to: "users#update"
        end
            
        scope ":username/send" do
            get "verification", to: "users#send_verification", as: "user_send_verification"
            get "reset", to: "users#send_password_reset", as: "user_send_password_reset"
            get "email", to: "users#prepare_email", as: "user_send_email"
            post "email", to: "users#send_email"
        end
    end
end