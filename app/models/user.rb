class User < ApplicationRecord
    has_one :setting, dependent: :destroy
    has_many :quizzes, dependent: :nullify
    has_many :bug_reports, dependent: :nullify

    ROLES = ["user", "beta", "admin"]

    validates :username, uniqueness: { case_sensitive: false }, format: { with: /\A\w{3,16}\z/ }
    validates :email, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :password, confirmation: true
    validates :agb, acceptance: true

    before_create do
        self.role = "user"
        self.confirmed = false
        self.sign_in_count = 1
        self.email = self.email.downcase

        encrypt_value :password, save: false

        send_verification_email save: false
    end

    after_create do
        self.create_setting
    end

    def admin?
        self.role == "admin"
    end

    def beta?
        self.role == "beta"
    end

    def change params
        errors = []
        self.username = params[:username] if params[:username].present?
        
        email_changed = false
        if params[:email].present? && params[:email].match?(URI::MailTo::EMAIL_REGEXP)
            user_with_email = User.find_by(email: params[:email]) || User.find_by(unconfirmed_email: params[:email])

            if !user_with_email.present? || user_with_email == self
                if params[:email].present? && params[:email] != self.email
                    self.unconfirmed_email = params[:email]
                    email_changed = true
                    unless send_verification_email
                        self.unconfirmed_email = nil
                        email_changed = false
                    end
                elsif params[:email] == self.email && self.unconfirmed_email.present?
                    self.unconfirmed_email = nil
                    self.confirmation_expire = nil
                    self.confirmation_token = nil
                end
            else
                errors.append("Ein anderer Benutzer verwendet diese E-mail Adresse schon")
            end
        else
            errors.append("E-mail ist ungültig") if params[:email].present?
        end

        if params[:password].present?
            if params[:password_confirmation].present? && params[:old_password].present?
                if compare_encrypted :password, params[:old_password]
                    if self.update(params.slice(:password, :password_confirmation))
                        encrypt_password
                    end
                else
                    errors.append(I18n.t("errors.old_password_no_match"))
                end
            else
                errors.append(I18n.t("errors.missing_password_fields"))
            end
        end

        self.save
        return [email_changed, get_errors.concat(errors)]
    end

    def send_reset_password_email
        self.password_reset_token = SecureRandom.hex 32
        self.password_reset_expire = Time.now + 7.days

        UserMailer.with(email: self.email, username: self.username, token: self.password_reset_token).password_reset_email.deliver_later
        encrypt_value :password_reset_token
    end
    
    def send_verification_email save: true
        if verified? && (!self.unconfirmed_email.present? || self.unconfirmed_email == self.email)
            return false
        end

        self.confirmation_token = SecureRandom.hex 32
        self.confirmation_expire = Time.now + 7.days
        
        if verified? && self.unconfirmed_email.present?
            UserMailer.with(email: self.unconfirmed_email, username: self.username, token: self.confirmation_token).verification_email.deliver_later
        else
            UserMailer.with(email: self.email, username: self.username, token: self.confirmation_token).verification_email.deliver_later
        end
        encrypt_value :confirmation_token, save: save
        return true
    end

    def verified?
        self.confirmed
    end

    def login password
        compare_encrypted :password, password
    end

    def compare_encrypted key, value
        for x in 0..8 do
            value = Digest::SHA256.hexdigest value
        end
        self[key] == value
    end

    def encrypt_password
        for x in 0..8 do
            self.password = Digest::SHA256.hexdigest self.password
            self.password_confirmation = Digest::SHA256.hexdigest self.password_confirmation
        end
        self.save
    end

    def encrypt_value key, save: true
        for x in 0..8 do
            self[key] = Digest::SHA256.hexdigest self[key]
        end
        self.save if save
    end

    def sign_in ip
        self.sign_in_count += 1
        self.last_sign_in_at = self.current_sign_in_at
        self.current_sign_in_at = Time.now
        self.last_sign_in_ip = self.current_sign_in_ip
        self.current_sign_in_ip = ip
        self.save
    end

    def get_errors
        errors = []
        for x in self.errors.objects do
            errors.append x.full_message
        end
        return errors
    end
end
