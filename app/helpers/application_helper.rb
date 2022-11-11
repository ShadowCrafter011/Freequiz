module ApplicationHelper
    def notice
        notice = session[:notice]
        session[:notice] = nil
        return notice.present? ? notice.split(";") : nil
    end
    def alert
        alert = session[:alert]
        session[:alert] = nil
        return alert.present? ? alert.split(";") : nil
    end
    def success
        success = session[:success]
        session[:success] = nil
        return success.present? ? success.split(";") : nil
    end
end
