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

    @user.change(edit_params)
  end

  private
    def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation, :agb)
    end

    def edit_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation, :old_password)
    end
end
