class User < ApplicationRecord
    before_create do
        self.role = "user"
        self.confirmation_token = SecureRandom.hex 32
        self.confirmation_expire = Time.now + 7.days
        self.current_sign_in_at = Time.now
    end

    after_create do
        UserMailer.with(user: self, token: self.confirmation_token).verification_email.deliver_later

        for x in 0..8 do
            self.confirmation_token = Digest::SHA256.hexdigest self.confirmation_token
        end
        self.save
    end
end
