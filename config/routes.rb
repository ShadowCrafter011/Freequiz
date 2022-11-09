Rails.application.routes.draw do
  root "home#root"

  draw :user
end
