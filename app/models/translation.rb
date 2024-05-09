class Translation < ApplicationRecord
    belongs_to :quiz, counter_cache: true
end
