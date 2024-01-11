module User::UserHelper
    def language_select
        language_selections = []
        Setting::LOCALES.each do |locale|
            language_selections.append([tg("languages.#{locale}"), locale])
        end
        language_selections
    end

    def create_items(hash)
        data = ""
        hash.each do |key, value|
            next unless value.present?

            data +=
                "
            <div class='row text-break'>
                <div class='col-6'>#{key}</div>
                <div class='col-6'>#{value}</div>
            </div>
            "
        end
        data.html_safe
    end

    def settings_form(form, _settings, order)
        data = ""
        order.each do |obj|
            attribute = obj[:attr]

            data +=
                "
            <div class='row fs-5'>
                <div class='col-6 text-start'>
                    #{form.label attribute, tg("settings.#{attribute}")}
                </div>
                <div class='col-6 form-check form-switch d-flex align-items-center justify-content-end'>
                    #{form.check_box attribute, class: "form-check-input", role: "switch"}
                </div>
            </div>
            "
            data += "<hr style='margin: 8px 0;'>" if obj[:hr]
        end
        data.html_safe
    end
end
