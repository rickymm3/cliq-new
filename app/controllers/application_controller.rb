class ApplicationController < ActionController::Base
  before_action :set_page_cliq
  before_action :set_root_cliq
  include Pagy::Backend

  def set_root_cliq
    @root_cliq = Cliq.root.first
    @categories = @root_cliq.child_cliqs
  end
  def set_page_cliq 
    @current_cliq = Cliq.first
  end
end
