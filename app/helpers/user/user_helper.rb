module User::UserHelper
    def create_items hash
        data = ""
        hash.each do |key, value|
            next unless hash[key].present?

            data += "
            <div class='row'>
                <div class='col-6'>#{key}</div>
                <div class='col-6'>#{hash[key]}</div>
            </div>
            "
        end
        data.html_safe
    end
end
