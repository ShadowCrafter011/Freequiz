class Api::UserController < ApplicationController
  include ApiUtils

  protect_from_forgery with: :null_session
  before_action :api_require_valid_bearer_token!
  skip_before_action :setup_login
  skip_around_action :switch_locale

  def create
    # json parameters like this:
    # {
    #   "username": "username",
    #   "email": "email",
    #   "password": "password", 
    #   "password_confirmation": "password",
    #   "agb": true
    # }

    return json({success: false, message: "Missing username, email, password, password_confirmation or agb"}, code: 400) unless validate_params :username, :email, :password, :password_confirmation, :agb

    return json({success: false, message: "Password doesn't meet requirements"}, code: 400) unless params[:password].match? /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}\z/

    user = User.new user_params
    user.current_sign_in_ip = request.remote_ip
    user.current_sign_in_at = Time.now

    if user.save
      json({
        success: true,
        message: "User created",
        access_token: generate_access_token(user)
      }, code: 201)
    else
      json({
        success: false,
        message: "Something went wrong whilst creating the user",
        errors: user.get_errors
      }, code: 400)
    end
  end

  def login
    return json({success: false, message: "Missing username or password"}, code: 400) unless validate_params :username, :password

    user = User.find_by(email: params[:username].downcase)

    unless user.present?
      user = User.where("lower(username) = ?", params[:username].downcase).first
    end

    return json({success: false, message: "User doesn't exist"}, code: :not_found) unless !!user

    return json({success: false, message: "Wrong password"}, code: 401) unless user.compare_encrypted :password, params[:password]
    
    user.sign_in request.remote_ip
    json({success: true, access_token: generate_access_token(user)})
  end

  def refresh_token
    return unless api_require_valid_access_token!
    json({success: true, access_token: refresh_access_token})
  end

  def request_delete_token
    return unless api_require_valid_access_token!

    token = SecureRandom.hex(32)
    @api_user.update(destroy_token: token, destroy_expire: 1.day.from_now)
    @api_user.encrypt_value :destroy_token

    json({success: true, token: token, expire: 1.day.from_now.to_i})
  end

  def destroy
    return unless api_require_valid_access_token!

    token = params[:destroy_token]

    if @api_user.compare_encrypted(:destroy_token, token) && @api_user.destroy_expire > Time.now
      @api_user.destroy
      json({success: true, message: "User deleted"})
    else
      json({success: false, message: "Couldn't delete user. Wrong token"}, code: :unauthorized)
    end
  end

  def update
    # json parameters like this:
    # {
    #   "user": {
    #     "username": "username",
    #     "email": "email",
    #     "password": "password", 
    #     "password_confirmation": "password",
    #     "old_password": "old_password"
    #   }
    # }

    return unless api_require_valid_access_token!

    if edit_params[:password].present?
      unless edit_params[:password].match? /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}\z/
        return json({success: false, message: "Password doesn't meet requirements"}, code: 400)
      end
    end

    email_changed, errors = @api_user.change edit_params

    return json({success: false, message: "Something went wrong whilst updating the user", errors: errors}, code: :bad_request) if errors.length > 0
    
    json({success: true, message: "User updated", email_changed: email_changed}, code: :accepted)
  end

  def update_settings
    # json parameters like this:
    # {
    #   "setting": {
    #     "dark_mode": true,
    #     "show_email": false
    #   }
    # }

    return unless api_require_valid_access_token!

    if @api_user.setting.update(setting_params)
      json({success: true, message: "Settings updated"})
    else
      json({success: false, message: "Something went wrong whilst saving the settings", errors: @api_user.setting.get_errors}, code: :bad_request)
    end
  end

  def data
    return unless api_require_valid_access_token!

    @settings = {}
    for key in Setting::SETTING_KEYS do
      @settings[key] = @api_user.setting[key]
    end
  end

  private
    def user_params
      params.require(:user).permit(:email, :username, :password, :password_confirmation, :agb)
    end

    def edit_params
      params.require(:user).permit(:email, :username, :password, :password_confirmation, :old_password)
    end

    def setting_params
      params.require(:setting).permit(Setting::SETTING_KEYS)
    end
end
