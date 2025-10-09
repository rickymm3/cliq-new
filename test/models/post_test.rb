require "test_helper"
require "securerandom"

class PostTest < ActiveSupport::TestCase
  setup do
    Notification.delete_all
  end

  test "notifies enabled subscribers of the cliq hierarchy on create" do
    author        = users(:alice)
    cliq          = cliqs(:child_cliq)
    root_cliq     = cliqs(:root_cliq)
    subscribed    = users(:bob)        # subscribed via fixtures to child_cliq
    ancestor_fan  = users(:carol)

    Subscription.create!(user: ancestor_fan, cliq: root_cliq, enabled: true)

    muted_user = User.create!(
      email: "muted-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    Subscription.create!(user: muted_user, cliq: cliq, enabled: false)

    post = nil
    assert_difference("Notification.count", 2) do
      post = Post.create!(
        title: "Notify subscribers #{SecureRandom.hex(4)}",
        cliq: cliq,
        user: author,
        post_type: :discussion
      )
    end

    recipient_ids = Notification.where(notifiable: post).pluck(:user_id).sort
    assert_equal [ancestor_fan.id, subscribed.id].sort, recipient_ids

    Notification.where(notifiable: post).each do |notification|
      assert_equal author.id, notification.actor_id
      assert_includes notification.message, cliq.name
      assert_includes notification.message, post.title
    end
  end

  test "article posts notify followers after commit" do
    author   = users(:alice)
    follower = users(:bob)
    FollowedUser.create!(follower: follower, followed: author)

    article_cliq = Cliq.create!(name: "Article Cliq #{SecureRandom.hex(6)}")

    post = nil
    assert_difference("Notification.count", 1) do
      post = Post.create!(
        title: "Article #{SecureRandom.hex(4)}",
        cliq: article_cliq,
        user: author,
        post_type: :article
      )
    end

    notification = Notification.find_by!(notifiable: post, user: follower)
    assert_equal author.id, notification.actor_id
    assert_includes notification.message, "New article"
  end

  test "non-article posts do not notify followers" do
    author   = users(:alice)
    follower = users(:bob)
    FollowedUser.create!(follower: follower, followed: author)
    cliq     = Cliq.create!(name: "Discussion Cliq #{SecureRandom.hex(6)}")

    assert_no_changes("Notification.count") do
      Post.create!(
        title: "Discussion #{SecureRandom.hex(4)}",
        cliq: cliq,
        user: author,
        post_type: :discussion
      )
    end
  end
end
