# app/controllers/profiles_controller.rb
class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @profile = Profile.find_by!(username: params[:id])
    @user    = @profile.user
  
    # (Optional) subscriptions section if you implemented Step 3 earlier
    if current_user&.id == @user.id && defined?(Subscription)
      @subscriptions     = @user.subscriptions.includes(cliq: :parent_cliq)
      @subscribed_groups = @user.subscribed_cliqs.includes(:parent_cliq).group_by { |c| c.ancestors.any? ? c.ancestors.first : c }
    end
  
    filter = params[:filter].presence || 'all'
    sort   = params[:sort].presence   || 'recent_activity'
  
    if filter == 'replies'
      @items = @user.replies.order(created_at: :desc)
    else
      base = Post.where(user_id: @user.id)
                 .left_joins(:replies)
                 .group('posts.id')
                 .includes(:user, :cliq)
                 .reorder(nil)
  
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
