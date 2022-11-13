class User::PasswordController < ApplicationController  
  def reset; end

  def send_email
    user = User.where("lower(username) = ?", params[:username].downcase)

    user = [User.find_by(email: params[:username].downcase)] unless user.first

    unless user.first && user.length == 1
      gn a: "Benutzername/E-mail Adresse scheint nicht zu stimmen"
      return render :new, status: 401
    end

    user.first.send_reset_password_email
    gn s: "E-mail wurde versendet. Schauen Sie in ihrem Postfach nach"
    redirect_to user_path
  end

  def edit
  end

  def update
  end
end
