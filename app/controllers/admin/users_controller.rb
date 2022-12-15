class Admin::UsersController < ApplicationController
    before_action :require_admin!

    def index
        @users = User.order(:username)
    end
end
