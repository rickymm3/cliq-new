# app/controllers/notifications_controller.rb
class NotificationsController < ApplicationController
  before_action :authenticate_user!

  # List notifications
  def index
    @notifications = current_user.notifications.order(created_at: :desc)
    # Mark all unread notifications as read
    current_user.notifications.unread.update_all(read_at: Time.current)
  end

  # Mark a single notification as read (if needed)
  def update
    @notification = current_user.notifications.find(params[:id])
    @notification.update(read_at: Time.current)
    redirect_to notifications_path
  end
end
