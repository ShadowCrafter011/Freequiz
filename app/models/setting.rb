class Setting < ApplicationRecord
  belongs_to :user

  SETTING_KEYS = [:dark_mode, :show_email]
  LOCALES = ["de", "fr", "it", "en"]

  validates :locale, inclusion: { in: LOCALES }

  before_create do
    self.dark_mode = false
    self.show_email = true
    self.locale = "de"
  end

  def get_errors
    errors = []
    for x in self.errors.objects do
        errors.append x.full_message
    end
    return errors
  end
end
