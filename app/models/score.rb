class Score < ApplicationRecord
    belongs_to :user, dependent: :destroy
    belongs_to :quiz, dependent: :destroy
end
