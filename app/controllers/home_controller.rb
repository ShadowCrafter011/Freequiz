class HomeController < ApplicationController
  before_action do
    setup_locale "home"
  end

  def search
    query = ActiveRecord::Base.connection.quote(params[:query])

    @users = User.find_by_sql("SELECT * FROM users ORDER BY SIMILARITY(username, #{query}) DESC LIMIT 50")
    @quizzes = Quiz.find_by_sql("SELECT * FROM quizzes WHERE visibility = 'public' ORDER BY SIMILARITY(title, #{query}) DESC LIMIT 50")
  end
  
  def root
  end
end
