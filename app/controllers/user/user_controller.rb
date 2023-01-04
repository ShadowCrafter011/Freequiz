class User::UserController < ApplicationController
  before_action do
    setup_locale "user.user"
  end
  before_action :require_login!, except: [:new, :create]

  def show
  end

  def quizzes
    @quizzes = current_user.quizzes
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

    unless user_params[:password].match? /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}\z/
      gn a: tg("password_regex")
      return render :new, status: :unprocessable_entity
    end

    @user.current_sign_in_ip = request.remote_ip
    @user.current_sign_in_at = Time.now

    if @user.save      
      cookies.encrypted[:_session_token] = { value: "#{@user.id};#{(Time.now + 14.days).to_i}", expires: Time.now + 14.days }
      
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
      unless edit_params[:password].match? /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}\z/
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

    cookies[:locale] = { value: @user.setting.locale, expires: 1.day.from_now }

    redirect_to user_settings_path
  end

  def request_destroy
    @token = SecureRandom.hex(32)
    @user.update(destroy_token: @token, destroy_expire: 1.days.from_now)
    @user.encrypt_value :destroy_token
  end

  def destroy
    token = params[:destroy_token]

    if @user.compare_encrypted(:destroy_token, token) && @user.destroy_expire > Time.now
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
