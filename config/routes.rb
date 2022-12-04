Rails.application.routes.draw do
  root "home#root"
  get "/test", to: "home#test"
  post "/test", to: "home#test"

  draw :user
  draw :api
end
