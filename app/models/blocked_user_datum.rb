class BlockedUserDatum < ApplicationRecord
    def self.username_blocked?(username)
        BlockedUserDatum.exists? username: username&.downcase
    end
end
