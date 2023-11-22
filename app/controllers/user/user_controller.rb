class User::UserController < ApplicationController
  before_action do
    setup_locale "user.user"
  end
  before_action :require_login!, except: [:new, :create, :public]

  def show
  end

  def public
    @target = User.find_by(username: params[:username])
    @quizzes = @target.quizzes.where("visibility = 'public'")
  end

  def quizzes
    @quizzes = current_user.quizzes.order(created_at: :desc)
  end

  def new
    if logged_in?
      gn n: tp("already_has_account")
      return redirect_to user_path
    end

    @user = User.new
  end

  def create
    override_action "new"

    @user = User.new(user_params)

    unless user_params[:password].match? (/\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}\z/)
      gn a: tg("password_regex")
      return render :new, status: :unprocessable_entity
    end

    @user.current_sign_in_ip = request.remote_ip
    @user.current_sign_in_at = Time.now

    if @user.save
      expires_in = 14.days
      token = @user.signed_id purpose: :login, expires_in: expires_in

      cookies.encrypted[:_session_token] = { value: token, expires: Time.now + expires_in }

      gn s: tp("created").sub("%s", @user.username)

      redirect_to user_verification_pending_path
    else
      gn a: @user.get_errors
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    override_action "edit"

    if edit_params[:password].present?
      unless edit_params[:password].match? (/\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}\z/)
        gn a: tg("password_regex")
        return render :edit, status: :unprocessable_entity
      end
    end

    email_changed, errors = @user.change(edit_params)
    if errors.length > 0
      gn a: errors
      render :edit, status: :unprocessable_entity
    else
      messages = [tp("saved_data")]
      messages.append(tp("new_email")) if email_changed
      gn s: messages
      redirect_to user_path
    end
  end

  def settings
  end

  def update_settings
    @user.setting.update(setting_params)
    gn s: tp("saved")

    session[:locale] = @user.setting.locale

    redirect_to user_settings_path
  end

  def request_destroy
    @token = @user.signed_id purpose: :destroy_user, expires_in: 1.day
  end

  def destroy
    user = User.find_signed params[:destroy_token], purpose: :destroy_user

    if user.present? && user == @user
      @user.destroy
      gn n: tp("deleted")
      redirect_to root_path
    else
      gn a: tp("failed")
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
      params.require(:setting).permit(Setting::SETTING_KEYS, :locale)
    end
end
