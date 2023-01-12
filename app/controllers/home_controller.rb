class HomeController < ApplicationController
  before_action do
    setup_locale "home"
  end

  def search
    query = ActiveRecord::Base.connection.quote(params[:query])
    @quizzes = params[:category] != "users"
    page = params[:page].to_i

    item_count = @quizzes ? Quiz.count : User.count
    @max_page = item_count / 50 + (item_count % 50 > 0 ? 1 : 0)
    @page = [page, @max_page].min
    offset = [0, @page * 50 - 50].max
    # puts "count: #{item_count}, max: #{@max_page}, q_page: #{page}, page: #{@page}, offset: #{offset}"

    available = Array(1..@max_page)
    index = available.index(@page)

    if available.length < 5
      @window = available
    elsif index >= 2 && index <= available.length - 3
      @window = available[(index - 2)..(index + 2)]
    elsif index < 2
      @window = available[0..4]
    else
      @window = available[(available.length - 5)..(available.length - 1)]
    end

    if @quizzes
      @results = Quiz.find_by_sql("SELECT * FROM quizzes WHERE visibility = 'public' ORDER BY SIMILARITY(title, #{query}) DESC LIMIT 50 OFFSET #{offset}")
    else
      @results = User.find_by_sql("SELECT * FROM users ORDER BY SIMILARITY(username, #{query}) DESC LIMIT 50 OFFSET #{offset}")
    end
  end
  
  def root; end
end
