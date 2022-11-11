class User::SessionsController < ApplicationController
  def new
  end
  
  def create
  end

  def destroy
    session[:user_id] = nil
    gn n: "Erfolgreich abgemeldet!"
    redirect_to root_path
  end
end
