class User < ApplicationRecord
    validates :username, uniqueness: { case_sensitive: false, message: "Benutzername wird schon von einem anderen Konto verwendet" }, format: { with: /\A\w{3,16}\z/, message: "Benutzername kann 3-16 Zeichen lang sein und darf nur Buchstaben, Zahlen und Unterstriche enthalten" }
    validates :email, uniqueness: { case_sensitive: false ,message: "Ein anderes Konto verwendet schon diese E-Mail Adresse" }, format: { with: URI::MailTo::EMAIL_REGEXP, message: "Diese Email Adresse ist nicht gültig" }
    validates :password, confirmation: { message: "Passwörter stimmen nicht überein" }, format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}\z/, message: "Passwort muss mindestens 8 Zeichen lang sein, einen Grossbuchstaben, einen Kleinbuchstaben und eine Zahl enthalten" }
    validates :agb, acceptance: { message: "Du must unsere Algemeinen Geschäftsbedingungen akzeptieren" }

    before_create do
        self.role = "user"
        self.confirmation_token = SecureRandom.hex 32
        self.confirmation_expire = Time.now + 7.days
        self.sign_in_count = 0
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
            msg = x.full_message
            errors.append msg.slice(msg.index(" "), msg.length)
        end
        return errors
    end
end
