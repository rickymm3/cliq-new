require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user  = users(:alice)
    @actor = users(:bob)
    @post  = posts(:discussion_post)
    Notification.delete_all
  end

  test "redirects unauthenticated users" do
    get notifications_path
    assert_redirected_to new_user_session_path
  end

  test "renders index with unread count" do
    Notification.create!(
      user: @user,
      actor: @actor,
      notifiable: @post,
      message: "Test notification"
    )

    sign_in @user
    get notifications_path

    assert_response :success
    assert_select "h1", text: "Notifications"
    assert_select "button", /Mark all as read/
    assert_select ".card-body", /Test notification/
  end

  test "mark_all_read updates unread notifications for current user only" do
    own_notification = Notification.create!(
      user: @user,
      actor: @actor,
      notifiable: @post,
      message: "Unread for user"
    )
    other_user = users(:carol)
    Notification.create!(
      user: other_user,
      actor: @actor,
      notifiable: @post,
      message: "Other user's notification"
    )

    sign_in @user
    patch mark_all_read_notifications_path

    assert_redirected_to notifications_path
    assert_not_nil own_notification.reload.read_at
    assert_nil Notification.find_by(user: other_user).read_at
  end

  test "update marks a notification read and redirects to target" do
    notification = Notification.create!(
      user: @user,
      actor: @actor,
      notifiable: @post,
      message: "Visit post"
    )

    sign_in @user
    patch notification_path(notification)

    assert_redirected_to post_id_slug_post_path(post_id: @post.id, slug: @post.slug)
    assert_not_nil notification.reload.read_at
  end
end
