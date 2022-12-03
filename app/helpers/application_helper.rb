module ApplicationHelper
    def tl attribute
        t "views.#{controller_name}.#{action_name}.#{attribute}"
    end

    def tlg attribute
        t "views.#{controller_name}.general.#{attribute}"
    end

    def tg attribute
        t "general.#{attribute}"
    end

    def notifications
        notifications = session[:notifications]
        session[:notifications] = nil
        return notifications.present? ? notifications : nil
    end
end
