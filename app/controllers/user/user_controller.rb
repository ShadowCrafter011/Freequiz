class User::UserController < ApplicationController
  def show
    return unless require_login!
  end

  def new
    if logged_in?
      gn n: "Du hast schon ein Konto"
      return redirect_to user_path
    end

    @user = User.new
  end

  def create
    @user = User.new(user_params)

    unless user_params[:password].match? /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}\z/
      gn a: "Passwort muss mindestens 8 Zeichen lang sein, einen Grossbuchstaben, einen Kleinbuchstaben und eine Zahl enthalten"
      return render :new, status: :unprocessable_entity
    end

    @user.current_sign_in_ip = request.remote_ip
    @user.current_sign_in_at = Time.now

    if @user.save      
      cookies.encrypted[:_session_token] = { value: "#{@user.id};#{(Time.now + 14.days).to_i}", expires: Time.now + 14.days }
      
      gn s: "Konto erfolgreich erstellt! Wilkommen bei Freequiz #{@user.username}!"

      redirect_to user_verification_pending_path
    else
      gn a: @user.get_errors
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    return unless require_login!
  end

  def update
    return unless require_login!

    if edit_params[:password].present?
      unless edit_params[:password].match? /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}\z/
        gn a: "Passwort muss mindestens 8 Zeichen lang sein, einen Grossbuchstaben, einen Kleinbuchstaben und eine Zahl enthalten"
        return render :edit, status: :unprocessable_entity
      end
    end
    
    email_changed, errors = @user.change(edit_params)
    if errors.length > 0
      gn a: errors
      render :edit, status: :unprocessable_entity
    else
      messages = ["Daten gespeichert!"]
      messages.append("Ihre neue E-mail Adresse wird verwendet sobald Sie den Link der in Ihr Postfach geschickt wurde geklickt haben") if email_changed
      gn s: messages
      redirect_to user_path
    end
  end

  def settings
    return unless require_login!
  end

  def update_settings
    return unless require_login!

    @user.setting.update(setting_params)
    gn s: "Einstellungen gespeichert"
    redirect_to user_settings_path
  end

  def request_destroy
    return unless require_login!

    @token = SecureRandom.hex(32)
    @user.update(destroy_token: @token, destroy_expire: 1.days.from_now)
    @user.encrypt_value :destroy_token
  end

  def destroy
    return unless require_login!

    token = params[:destroy_token]

    if @user.compare_encrypted(:destroy_token, token) && @user.destroy_expire > Time.now
      @user.destroy
      gn n: "Konto gelöscht. Schade, dass Sie gehen"
      redirect_to root_path
    else
      gn a: "Etwas ist schief geloffen. Kontaktieren Sie unseren Support wenn dies nochmal passiert"
      redirect_to user_path
    end
  end

  private
    def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation, :agb)
    end

    def edit_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation, :old_password)
    end

    def setting_params
      params.require(:setting).permit(:show_email, :dark_mode)
    end
end
