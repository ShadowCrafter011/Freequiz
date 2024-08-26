class BlockedUserDatum < ApplicationRecord
    @blocked_usernames = []

    def self.username_blocked?(username)
        if @blocked_usernames.count != BlockedUserDatum.count
            @blocked_usernames = []
            BlockedUserDatum.find_each do |blocked|
                @blocked_usernames.append(blocked.username)
            end
        end

        @blocked_usernames.include? username&.downcase
    end
end
