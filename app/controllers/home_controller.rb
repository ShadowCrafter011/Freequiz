class HomeController < ApplicationController
  before_action do
    setup_locale "home"
  end

  def search
    query = ActiveRecord::Base.connection.quote(params[:query])
    @quizzes = params[:category] != "users"
    page = params[:page].to_i

    offset = offset(page, @quizzes ? Quiz.count : User.count)
    @page = (offset + 50) / 50

    if @quizzes
      @results = Quiz.find_by_sql("SELECT * FROM quizzes WHERE visibility = 'public' ORDER BY SIMILARITY(title, #{query}) DESC LIMIT 50 OFFSET #{offset}")
    else
      @results = User.find_by_sql("SELECT * FROM users ORDER BY SIMILARITY(username, #{query}) DESC LIMIT 50 OFFSET #{offset}")
    end
  end
  
  def root; end

  private
  def offset page, item_count
    max_offset = item_count / 50 + (item_count % 50 > 0 ? 1 : 0)
    return max_offset * 50 - 50 if page > max_offset
    page * 50 - 50
  end
end
