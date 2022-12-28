class Language < ApplicationRecord
    def self.selection
        list = []
        for language in Language.all do
            list.append [I18n.t("general.languages.#{language.locale}"), language.id]
        end
        return list
    end
end
