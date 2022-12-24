class HomeController < ApplicationController
  before_action do
    setup_locale "home"
  end
  
  def root
  end

  def test
    render json: {nothing: "here"}, status: 200
  end
end
