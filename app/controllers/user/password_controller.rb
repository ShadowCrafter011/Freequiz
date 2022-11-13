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
    redirect_to root_path
  end

  def edit
    user, valid = validate_token
    return unless valid
  end

  def update
    user, valid = validate_token
    return unless valid

    unless password_params[:password].match? /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}\z/
      gn a: "Passwort muss mindestens 8 Zeichen lang sein, einen Grossbuchstaben, einen Kleinbuchstaben und eine Zahl enthalten"
      return render :edit, status: :unprocessable_entity
    end

    if user.update(password_params.merge(password_reset_token: nil, password_reset_expire: nil))
      user.encrypt_password

      expire = 14.days.from_now
      cookies.encrypted[:_session_token] = { value: "#{user.id};#{expire.to_i}", expires: expire }
      user.sign_in request.remote_ip
      puts "ERRORS #{user.get_errors}"
      gn s: "Passwort wurde geändert und du wurdest automatisch eingeloggt"
      redirect_to user_path
    else
      gn a: user.get_errors
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def password_params
      params.permit(:password, :password_confirmation)
    end

    def validate_token
      token = params[:password_reset_token]
      for x in 0..8 do
        token = Digest::SHA256.hexdigest token
      end

      unless User.exists? password_reset_token: token
        gn a: "Dieser Link ist nicht gültig. Fordern Sie hier einen neuen an"
        redirect_to user_password_reset_path

        return [nil, false]
      end
      user = User.find_by(password_reset_token: token)

      unless Time.now < user.password_reset_expire
        gn a: "Dieser Link ist abgeloffen. Fordern Sie hier einen neuen an"
        redirect_to user_password_reset_path

        return [nil, false]
      end

      return [user, true]
    end
end
