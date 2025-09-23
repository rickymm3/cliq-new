class ApplicationController < ActionController::Base
  before_action :set_page_cliq
  before_action :set_root_cliq
  before_action :initialize_cliqs
  before_action :store_user_location!, if: :storable_location?

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

  def storable_location?
    request.get? &&
      is_navigational_format? &&
      !devise_controller? &&
      !request.xhr?
  end

  def store_user_location!
    # Devise will pick this up
    store_location_for(:user, request.fullpath)
  end

  # On successful sign in, go back to where the user was.
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || request.referer || root_path
  end

  # On sign out, go back to where they came from (or home)
  def after_sign_out_path_for(resource_or_scope)
    request.referer || root_path
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end

  def initialize_cliqs
    @cliqs ||= []
  end
  
end
