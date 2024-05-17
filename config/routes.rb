Rails.application.routes.draw do
    root "home#root"
    get "sponsors", to: "home#sponsors", as: "sponsors"

    get "search", to: "home#search", as: "search"

    draw :user
    draw :quiz
    draw :bug_reports
    draw :api

    draw :admin

    draw :errors
end
