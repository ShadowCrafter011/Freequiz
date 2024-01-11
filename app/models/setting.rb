class Setting < ApplicationRecord
    belongs_to :user

    SETTING_KEYS = %i[dark_mode show_email].freeze
    LOCALES = %w[de fr it en].freeze

    validates :locale, inclusion: { in: LOCALES }

    after_create do
        self.dark_mode = false
        self.show_email = true
    end

    def get_errors
        errors = []
        self.errors.objects.each do |x|
            errors.append x.full_message
        end
        errors
    end
end
