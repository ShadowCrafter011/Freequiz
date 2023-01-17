namespace :admin do
    get "users", to: "users#index", as: "users"

    scope :transactions do
        get "/", to: "transaction#list", as: "transactions"
        get "removed", to: "transaction#removed", as: "removed_transactions"

        get "create", to: "transaction#new", as: "new_transaction"
        post "create", to: "transaction#create"
        
        scope ":transaction_id" do
            get "/", to: "transaction#show", as: "show_transaction"

            delete "delete", to: "transaction#delete", as: "delete_transaction"
            patch "restore", to: "transaction#restore", as: "restore_transaction"
        end
    end
    
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