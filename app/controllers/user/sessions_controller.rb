class User::SessionsController < ApplicationController
  def new
  end
  
  def create
  end

  def destroy
    cookies.delete :_session_token
    gn n: "Erfolgreich abgemeldet!"
    redirect_to root_path
  end
end
