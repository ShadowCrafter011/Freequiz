module ApplicationHelper
    def notice
        notice = session[:notice]
        session[:notice] = nil
        return notice
    end
    def alert
        alert = session[:alert]
        session[:alert] = nil
        return alert
    end
    def success
        success = session[:success]
        session[:success] = nil
        return success
    end
end
