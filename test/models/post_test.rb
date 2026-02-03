require "test_helper"
require "securerandom"

class PostTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers
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

  test "heat score crosses threshold and awards hot window" do
    author = users(:alice)
    cliq   = cliqs(:child_cliq)

    travel_to Time.zone.local(2024, 1, 1, 12) do
      post = Post.create!(
        title: "Heat threshold #{SecureRandom.hex(3)}",
        cliq: cliq,
        user: author,
        post_type: :discussion
      )

      post.reload
      assert_in_delta 10.0, post.heat_score, 0.01
      refute post.hot?

      6.times { post.bump_heat!(:reply) } # replies give the biggest boost
      post.reload

      assert post.hot?
      assert_not_nil post.hot_until
      assert_in_delta (Time.current + Post::HOT_DURATION).to_i, post.hot_until.to_i, 1
    end
  end

  test "heat decays and hot flag clears after window" do
    author = users(:alice)
    cliq   = cliqs(:child_cliq)

    travel_to Time.zone.local(2024, 1, 1, 12) do
      post = Post.create!(
        title: "Heat decay #{SecureRandom.hex(3)}",
        cliq: cliq,
        user: author,
        post_type: :discussion
      )

      6.times { post.bump_heat!(:reply) }
      post.reload
      assert post.hot?
      initial_hot_until = post.hot_until

      travel_to Time.current + 25.hours do
        post.reload
        refute post.hot?
        assert initial_hot_until < Time.current

        post.register_view! # apply decay and drop stale hot window
        post.reload
        assert_nil post.hot_until
        assert post.heat_score < Post::HEAT_THRESHOLD
      end
    end
  end
end
