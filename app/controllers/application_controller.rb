class ApplicationController < ActionController::Base
  before_action :set_page_cliq
  before_action :set_root_cliq
  include Pagy::Backend
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def set_root_cliq
    @root_cliq = Cliq.root.first
    @categories = @root_cliq.child_cliqs
  end
  def set_page_cliq 
    @current_cliq = Cliq.first
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
  
end
