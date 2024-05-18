namespace :api do
    defaults format: :json do
        scope :user do
            put "create", to: "user#create"
            post "login", to: "user#login"
            post "refresh", to: "user#refresh_token"

            get "exists/:attr/:query", to: "user#exists"

            get "search(/:page)", to: "user#search"

            get "quizzes(/:page)", to: "user#quizzes"
            get ":username/public(/:page)", to: "user#public"

            get "delete_token", to: "user#request_delete_token"
            delete "delete/:destroy_token", to: "user#destroy"

            patch "update", to: "user#update"
            patch "settings", to: "user#update_settings"

            get "data", to: "user#data"
        end

        scope :quiz do
            put "create", to: "quiz#create"

            get "search(/:page)", to: "quiz#search"

            scope ":quiz_id" do
                get "data", to: "quiz#data"

                patch "update", to: "quiz#update"
                patch "favorite", to: "quiz#favorite_quiz"

                scope :score do
                    patch "reset/:mode", to: "quiz#reset_score"
                    patch ":score_id/favorite", to: "quiz#favorite"
                    patch ":score_id/:mode", to: "quiz#score"
                end

                get "delete_token", to: "quiz#request_destroy"
                delete "delete/:destroy_token", to: "quiz#destroy"
            end
        end

        get "languages", to: "api#languages"

        put "bug/create", to: "bug_report#create"
    end

    scope :docs do
        get "/", to: "docs#index", as: "docs"
        get "users", to: "docs#users", as: "docs_users"
        get "quizzes", to: "docs#quizzes", as: "docs_quizzes"
        get "authentication", to: "docs#authentication", as: "docs_authentication"
        get "errors", to: "docs#general_errors", as: "docs_general_errors"
        get "bugs", to: "docs#bugs", as: "docs_bugs"
        get "languages", to: "docs#languages", as: "docs_languages"
    end
end
