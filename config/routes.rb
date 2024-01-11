Rails.application.routes.draw do
    root "home#root"

    get "search", to: "home#search", as: "search"

    get "user/:username", to: "user/user#public", as: "user_public"

    draw :user
    draw :quiz
    draw :bug_reports
    draw :api

    draw :admin

    draw :errors
end
