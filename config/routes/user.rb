scope :account do
    get "/", to: "user/user#show", as: "user"
    get "edit", to: "user/user#edit", as: "user_edit"
    post "edit", to: "user/user#update"
end

scope :password do
    get "reset", to: "user/password#reset", as: "user_password_reset"
    post "reset", to: "user/password#send"

    get "edit/:password_reset_token", to: "user/passwords#edit", as: "user_password_edit"
    post "edit/:password_reset_token", to: "user/passwords#update"
end

scope :verify do
    get "send", to: "user/verification#send", as: "user_verification_send"
    get "pending", to: "user/verification#pending", as: "user_verification_pending"
    get ":verification_token", to: "user/verification#verify", as: "user_verify"
end

get "sign_up", to: "user/user#new", as: "user_create"
post "sign_up", to: "user/user#create"

get "login", to: "user/sessions#new", as: "user_login"
post "login", to: "user/sessions#create"

get "logout", to: "user/sessions#destroy", as: "user_logout"