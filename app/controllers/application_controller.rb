class ApplicationController < ActionController::Base
    def generate_notification **messages
        @notifications = messages
    end

    def gn **messages
        generate_notification :notice => messages[:n], :alert => messages[:a], :success => messages[:s]
    end
end
