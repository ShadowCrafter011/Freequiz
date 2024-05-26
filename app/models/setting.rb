class Setting < ApplicationRecord
    belongs_to :user

    SETTING_KEYS = %i[dark_mode write_amount cards_amount multi_amount].freeze
    LOCALES = %w[de fr it en].freeze

    validates :locale, inclusion: { in: LOCALES }
    validates :write_amount, numericality: { only_integer: true, in: 1..3 }
    validates :cards_amount, numericality: { only_integer: true, in: 1..3 }
    validates :multi_amount, numericality: { only_integer: true, in: 1..3 }

    def get_errors
        errors = []
        self.errors.objects.each do |x|
            errors.append x.full_message
        end
        errors
    end
end
