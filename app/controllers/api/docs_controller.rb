class Api::DocsController < ApplicationController
  before_action :require_admin!
  
  def index; end
  def users; end
  def authentication; end
  def general_errors; end
end
