class User::UserController < ApplicationController
  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params.except(:password, :password_confirmation))
    
    unless user_params[:agb] == "1"
      gn a: "Du must unsere AGBs akzeptieren"
      return render :new, status: :unprocessable_entity
    end

    unless user_params[:password] == user_params[:password_confirmation]
      gn a: "Passwörter stimmen nicht überein"
      return render :new, status: :unprocessable_entity
    end

    if User.find_by(email: @user.email).present?
      gn a: "E-Mail wird schon von einem anderen Konto verwendet"
      return render :new, status: :unprocessable_entity
    end

    if User.find_by(username: @user.username).present?
      gn a: "Benutzername wird schon von einem anderen Konto verwendet"
      return render :new, status: :unprocessable_entity
    end

    unless user_params[:password].match? /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}\z/
      gn a: "Passwort muss mindestens 8 Zeichen lang sein, einen Grossbuchstaben, einen Kleinbuchstaben und eine Zahl enthalten"
      return render :new, status: :unprocessable_entity
    end

    unless @user.email.match? URI::MailTo::EMAIL_REGEXP
      gn a: "Diese Email Adresse ist nicht gültig"
      return render :new, status: :unprocessable_entity
    end

    unless @user.username.match? /\A\w{3,16}\z/
      gn a: "Benutzername kann 3-16 Zeichen lang sein und darf nur Buchstaben, Zahlen und Unterstriche enthalten"
      return render :new, status: :unprocessable_entity
    end

    password_digest = user_params[:password]
    for _ in 0..8 do
      password_digest = Digest::SHA512.hexdigest password_digest
    end
    @user.password_digest = password_digest
    @user.current_sign_in_ip = request.remote_ip

    if @user.save
      gn s: "Konto erfolgreich erstellt! Wilkommen bei Freequiz #{@user.username}!"
      session[:user_id] = @user.id
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
  end

  private
    def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation, :agb)
    end
end
