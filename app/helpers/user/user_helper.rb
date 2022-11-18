module User::UserHelper
    def create_items hash
        data = ""
        hash.each do |key, value|
            next unless value.present?

            data += "
            <div class='row text-break'>
                <div class='col-6'>#{key}</div>
                <div class='col-6'>#{value}</div>
            </div>
            "
        end
        data.html_safe
    end
end
