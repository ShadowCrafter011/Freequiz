module ApplicationHelper
    def notifications
        notifications = session[:notifications]
        session[:notifications] = nil
        notifications.present? ? notifications : nil
    end
end
