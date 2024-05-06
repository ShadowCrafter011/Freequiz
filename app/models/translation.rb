class Translation < ApplicationRecord
    belongs_to :quiz, dependent: :destroy
end
