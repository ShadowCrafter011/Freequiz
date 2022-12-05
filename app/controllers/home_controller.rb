class HomeController < ApplicationController
  def root
  end

  def test
    render json: {nothing: "here"}, status: 200
  end
end
