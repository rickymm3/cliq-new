# app/controllers/profiles_controller.rb
class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    # Look up the Profile by its username (which is provided as params[:id])
    @profile = Profile.find_by!(username: params[:id])
    @user = @profile.user

    filter = params[:filter] || 'all'
    sort   = params[:sort]   || 'recent_activity'

    if filter == 'posts'
      @items = @user.posts.order(sort_order(sort))
    elsif filter == 'replies'
      @items = @user.replies.order(created_at: :desc)
    else
      posts   = @user.posts.to_a
      replies = @user.replies.to_a
      @items  = (posts + replies).sort_by { |item| activity_time(item) }.reverse
    end
  end

  private

  def sort_order(sort)
    case sort
    when 'created'
      { created_at: :desc }
    else
      { updated_at: :desc }
    end
  end

  def activity_time(item)
    item.is_a?(Post) ? item.updated_at : item.created_at
  end
end
