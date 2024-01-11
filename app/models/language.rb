class Language < ApplicationRecord
    validates :name, uniqueness: { case_sensitive: false }
    validates :locale, uniqueness: { case_sensitive: false }

    def self.selection
        list = []
        Language.all.each do |language|
            list.append [I18n.t("general.languages.#{language.locale}"), language.id]
        end
        list
    end
end
