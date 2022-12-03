class User::SessionsController < ApplicationController
  def new
    if logged_in?
      gn n: tl("already_logged_in")
      redirect_to user_path
    end
    @params = params[:gg]
  end
  
  def create
    user = User.where("lower(username) = ?", params[:username].downcase)

    user = [User.find_by(email: params[:username].downcase)] unless user.first

    unless user.first && user.length == 1
      gn a: tl("wrong_username")
      return render :new, status: 401
    end

    if user.first.login params[:password]
      expire = Time.now + (params[:remember] == "1" ? 14.days : 1.days)
      cookies.encrypted[:_session_token] = { value: "#{user.first.id};#{expire.to_i}", expires: expire }

      gn s: tl("success").sub("%s", user.first.username)

      user.first.sign_in request.remote_ip
      redirect_to (params[:gg].present? ? params[:gg] : user_path)
    else
      gn a: tl("wrong_password")
      render :new, status: 401
    end
  end

  def destroy
    cookies.delete :_session_token
    gn n: tl("success")
    redirect_to user_login_path
  end
end
