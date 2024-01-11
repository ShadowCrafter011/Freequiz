class User < ApplicationRecord
    has_one :setting, dependent: :destroy
    has_many :quizzes, dependent: :nullify
    has_many :scores, dependent: :destroy
    has_many :bug_reports, dependent: :nullify
    has_many :transactions, dependent: :nullify

    ROLES = %w[user beta admin].freeze

    validates :username,
              uniqueness: {
                  case_sensitive: false
              },
              format: {
                  with: /\A\w{3,16}\z/
              }
    validates :email,
              uniqueness: {
                  case_sensitive: false
              },
              format: {
                  with: URI::MailTo::EMAIL_REGEXP
              }
    validates :password, confirmation: true
    validates :agb, acceptance: true

    before_create do
        self.role = "user" unless role.present?
        self.confirmed = false
        self.sign_in_count = 1
        self.email = email.downcase

        encrypt_value :password, save: false
    end

    after_create do
        create_setting
        send_verification_email
    end

    def admin?
        role == "admin"
    end

    def beta?
        role == "beta"
    end

    def change(params)
        errors = []
        self.username = params[:username] if params[:username].present?

        email_changed = false
        if params[:email].present? &&
           params[:email].match?(URI::MailTo::EMAIL_REGEXP)
            user_with_email =
                User.find_by(email: params[:email]) ||
                User.find_by(unconfirmed_email: params[:email])

            if !user_with_email.present? || user_with_email == self
                if params[:email].present? && params[:email] != email
                    self.unconfirmed_email = params[:email]
                    email_changed = true
                    unless send_verification_email
                        self.unconfirmed_email = nil
                        email_changed = false
                    end
                elsif params[:email] == email && unconfirmed_email.present?
                    self.unconfirmed_email = nil
                end
            else
                errors.append(
                    "Ein anderer Benutzer verwendet diese E-mail Adresse schon"
                )
            end
        elsif params[:email].present?
            errors.append("E-mail ist ungültig")
        end

        if params[:password].present?
            if params[:password_confirmation].present? &&
               params[:old_password].present?
                if compare_encrypted :password, params[:old_password]
                    encrypt_password if update(params.slice(:password, :password_confirmation))
                else
                    errors.append(I18n.t("errors.old_password_no_match"))
                end
            else
                errors.append(I18n.t("errors.missing_password_fields"))
            end
        end

        save
        [email_changed, get_errors.concat(errors)]
    end

    def send_reset_password_email
        token = signed_id purpose: :reset_password, expires_in: 1.day
        UserMailer
            .with(email:, username:, token:)
            .password_reset_email
            .deliver_later
    end

    def send_verification_email
        if verified? &&
           (
               !unconfirmed_email.present? ||
                   unconfirmed_email == email
           )
            return false
        end

        token = signed_id purpose: :verify_email, expires_in: 7.days

        if verified? && unconfirmed_email.present?
            UserMailer
                .with(
                    email: unconfirmed_email,
                    username:,
                    token:
                )
                .verification_email
                .deliver_later
        else
            UserMailer
                .with(email:, username:, token:)
                .verification_email
                .deliver_later
        end
        true
    end

    def verified?
        confirmed
    end

    def login(password)
        compare_encrypted :password, password
    end

    def compare_encrypted(key, value)
        9.times do
            value = Digest::SHA256.hexdigest value
        end
        self[key] == value
    end

    def encrypt_password
        9.times do
            self.password = Digest::SHA256.hexdigest password
            self.password_confirmation =
                Digest::SHA256.hexdigest password_confirmation
        end
        save
    end

    def encrypt_value(key, save: true)
        9.times do
            self[key] = Digest::SHA256.hexdigest self[key]
        end
        self.save if save
    end

    def sign_in(ip)
        self.sign_in_count += 1
        self.last_sign_in_at = current_sign_in_at
        self.current_sign_in_at = Time.now
        self.last_sign_in_ip = current_sign_in_ip
        self.current_sign_in_ip = ip
        save
    end

    def get_errors
        errors.full_messages
    end
end
