# app/controllers/profiles_controller.rb
class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    # Look up the Profile by its username (which is provided as params[:id])
    @profile = Profile.find_by!(username: params[:id])
    @user = @profile.user
  
    # Subscribed cliqs (for the owner) — leave as-is from earlier step if present.
    if current_user&.id == @user.id
      @subscriptions = @user.subscriptions.includes(cliq: :parent_cliq) if defined?(Subscription)
      @subscribed_groups = @user.subscribed_cliqs.includes(:parent_cliq).group_by { |c| c.ancestors.any? ? c.ancestors.first : c } if defined?(Subscription)
    end
  
    filter = params[:filter].presence || 'all'
    sort   = params[:sort].presence   || 'recent_activity'
  
    if filter == 'replies'
      # Replies remain a simple list for now.
      @items = @user.replies.order(created_at: :desc)
    else
      # Reuse Cliqs#show logic: latest activity (newest reply OR post created)
      base = Post.where(user_id: @user.id)
                 .left_joins(:replies)        # bring in replies for MAX()
                 .group('posts.id')           # needed for the aggregate
                 .includes(:user, :cliq)
                 .reorder(nil)                # clear prior ORDERs
  
      order_expr = 'GREATEST(posts.created_at, COALESCE(MAX(replies.created_at), posts.created_at)) DESC'
      @pagy, @posts = pagy(base.order(Arel.sql(order_expr)))
    end
  
    respond_to do |f|
      f.html
      f.turbo_stream
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
