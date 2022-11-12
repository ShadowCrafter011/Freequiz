module ApplicationHelper
    def notifications
        notifications = session[:notifications]
        session[:notifications] = nil
        return notifications.present? ? notifications : nil
    end
end
