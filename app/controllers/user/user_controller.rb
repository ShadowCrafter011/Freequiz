class User::UserController < ApplicationController
  def show
    return unless require_login!
    @user = current_user
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      @user.sign_in request.remote_ip
      session[:user_id] = @user.id

      gn s: "Konto erfolgreich erstellt! Wilkommen bei Freequiz #{@user.username}!"

      redirect_to user_path
    else
      gn a: @user.get_errors.join(";")
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
