class User::PasswordController < ApplicationController  
  def reset; end

  def send_email
    user = User.where("lower(username) = ?", params[:username].downcase)

    user = [User.find_by(email: params[:username].downcase)] unless user.first

    unless user.first && user.length == 1
      gn a: tl("wrong_username")
      return render :reset, status: 401
    end

    user.first.send_reset_password_email
    gn s: tl("sent_email")
    redirect_to root_path
  end

  def edit
    user, valid = validate_token
    return unless valid
  end

  def update
    user, valid = validate_token
    return unless valid

    unless params[:password].match? /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}\z/
      gn a: tl("password_regex")
      return render :edit, status: :unprocessable_entity
    end

    if user.update(password: params[:password], password_confirmation: params[:password_confirmation], password_reset_token: nil, password_reset_expire: nil)
      user.encrypt_password

      expire = 14.days.from_now
      cookies.encrypted[:_session_token] = { value: "#{user.id};#{expire.to_i}", expires: expire }
      user.sign_in request.remote_ip

      gn s: tl("changed_password")
      redirect_to user_path
    else
      gn a: user.get_errors
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def validate_token
      token = params[:password_reset_token]
      for x in 0..8 do
        token = Digest::SHA256.hexdigest token
      end

      if (user = User.find_by(password_reset_token: token)).present?
        unless Time.now < user.password_reset_expire
          gn a: tlg("link_expired")
          redirect_to user_password_reset_path
  
          return [nil, false]
        end
  
        return [user, true]
      end
      
      gn a: tlg("invalid_link")
      redirect_to user_password_reset_path

      return [nil, false]
    end
end
