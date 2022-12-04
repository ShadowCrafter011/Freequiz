class HomeController < ApplicationController
  protect_from_forgery with: :null_session

  def root
  end

  def test
    render json: params[:test], status: 200
  end
end
