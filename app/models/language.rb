class Language < ApplicationRecord
    validates :name, uniqueness: { case_sensitive: false }
    validates :locale, uniqueness: { case_sensitive: false }
end
