class User::SessionsController < ApplicationController
  def new
    if logged_in?
      gn n: "Du bist schon angemeldet"
      redirect_to user_path
    end
    @params = params[:gg]
  end
  
  def create
    user = User.where("lower(username) = ?", params[:username].downcase)

    user = [User.find_by(email: params[:username].downcase)] unless user.first

    unless user.first && user.length == 1
      gn a: "Benutzername/E-mail Adresse scheint nicht zu stimmen"
      return render :new, status: 401
    end

    if user.first.login login_params[:password]
      expire = Time.now + (login_params[:remember] == "1" ? 14.days : 1.days)
      cookies.encrypted[:_session_token] = { value: "#{user.first.id};#{expire.to_i}", expires: expire }

      gn s: "Erfolgreich angemeldet! Wilkommen zurück #{user.first.username}!"

      user.first.sign_in request.remote_ip
      redirect_to (params[:gg].present? ? params[:gg] : user_path)
    else
      gn a: "Passwort passt nicht zum angegebenen Konto"
      render :new, status: 401
    end
  end

  def destroy
    cookies.delete :_session_token
    gn n: "Erfolgreich abgemeldet!"
    redirect_to user_login_path
  end

  private
    def login_params
      params.permit(:username, :password, :remember, :goto)
    end
end
