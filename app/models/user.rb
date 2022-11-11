class User < ApplicationRecord
    validates :username, uniqueness: { case_sensitive: false }, format: { with: /\A\w{3,16}\z/ }
    validates :email, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :password, confirmation: true, format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}\z/ }
    validates :agb, acceptance: true

    before_create do
        self.role = "user"
        self.confirmation_token = SecureRandom.hex 32
        self.confirmation_expire = Time.now + 7.days
        self.sign_in_count = 0
        encrypt_value :password
    end

    after_create do
        UserMailer.with(user: self, token: self.confirmation_token).verification_email.deliver_later
        encrypt_value :confirmation_token
    end

    def encrypt_value key
        for x in 0..8 do
            self[key] = Digest::SHA256.hexdigest self[key]
        end
        self.save
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
