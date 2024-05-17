class Score < ApplicationRecord
    belongs_to :user
    belongs_to :translation

    MODES = %i[cards write multi smart].freeze
end
