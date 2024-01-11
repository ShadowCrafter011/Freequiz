module Admin::TransactionHelper
    def color(value)
        value = value.to_f
        return "success" if value > 0.0
        return "secondary" if value == 0.0

        "danger" if value < 0.0
    end
end
