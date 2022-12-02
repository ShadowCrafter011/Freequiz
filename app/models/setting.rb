class Setting < ApplicationRecord
  belongs_to :user

  before_create do
    self.dark_mode = false
    self.show_email = true
  end
end
