class User < ApplicationRecord
    before_create do
        # TODO: send verification email and digest the confirmation token after sending
        self.role = "user"
        self.confirmation_token = SecureRandom.hex 32
        self.confirmation_expire = Time.now + 7.days
        self.current_sign_in_at = Time.now
    end
end
