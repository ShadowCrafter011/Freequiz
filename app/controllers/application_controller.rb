class ApplicationController < ActionController::Base
    def generate_notification **messages
        session[:alert] = messages[:alert] if messages[:alert].present?
        session[:success] = messages[:success] if messages[:success].present?
        session[:notice] = messages[:notice] if messages[:notice].present?
    end

    def gn **messages
        generate_notification :notice => messages[:n], :alert => messages[:a], :success => messages[:s]
    end
end
