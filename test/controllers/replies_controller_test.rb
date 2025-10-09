require "test_helper"
require "securerandom"

class RepliesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:discussion_post)
    @reply = replies(:discussion_reply)
    @user = users(:bob)
  end

  test "guest redirected from new" do
    get new_reply_url(post_id: @post.id)
    assert_redirected_to new_user_session_url
  end

  test "authenticated user can get new" do
    sign_in @user
    get new_reply_url(post_id: @post.id)
    assert_response :success
  end

  test "should show reply" do
    get reply_url(@reply)
    assert_response :success
  end

  test "should create reply" do
    sign_in @user
    assert_difference("Reply.count") do
      post replies_url, params: {
        reply: {
          post_id: @post.id,
          content: "<div>Reply #{SecureRandom.hex(3)}</div>"
        }
      }
    end

    created = Reply.order(:created_at).last
    assert_redirected_to post_path(created.post)
  end

  test "should update reply" do
    sign_in @user
    patch reply_url(@reply), params: { reply: { content: "<div>Updated</div>" } }
    assert_redirected_to post_path(@reply.post)
    assert_includes @reply.reload.content.body.to_s, "Updated"
  end

  test "should destroy reply" do
    sign_in @user
    disposable = Reply.create!(
      post: @post,
      user: @user,
      content: "<div>Disposable</div>"
    )
    assert_difference("Reply.count", -1) do
      delete reply_url(disposable)
    end

    assert_redirected_to post_path(@post)
  end
end
