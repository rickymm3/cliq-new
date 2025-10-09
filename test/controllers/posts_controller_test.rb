require "test_helper"
require "securerandom"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cliq = cliqs(:child_cliq)
    @user = users(:alice)
    @post = posts(:discussion_post)
  end

  test "should get index" do
    get posts_url
    assert_response :success
  end

  test "guest redirected on new" do
    get new_post_url
    assert_redirected_to new_user_session_url
  end

  test "authenticated user can access new" do
    sign_in @user
    get new_post_url
    assert_response :success
  end

  test "should create post" do
    sign_in @user
    assert_difference("Post.count") do
      post posts_url, params: {
        post: {
          title: "Controller Test #{SecureRandom.hex(3)}",
          content: "<div>Some content</div>",
          cliq_id: @cliq.id,
          post_type: "discussion"
        }
      }
    end

    created = Post.order(:created_at).last
    assert_redirected_to post_id_slug_post_url(post_id: created.id, slug: created.slug)
  end

  test "should show post" do
    get post_id_slug_post_url(post_id: @post.id, slug: @post.slug)
    assert_response :success
  end

  test "should get edit for owner" do
    sign_in @user
    get edit_post_url(@post.id)
    assert_response :success
  end

  test "should update post" do
    sign_in @user
    patch post_url(@post.id), params: { post: { title: "Updated title" } }
    @post.reload
    assert_redirected_to post_id_slug_post_url(post_id: @post.id, slug: @post.slug)
    assert_equal "Updated title", @post.title
  end

  test "should destroy post" do
    sign_in @user
    disposable = Post.create!(
      title: "Disposable #{SecureRandom.hex(3)}",
      content: "<div>Disposable content</div>",
      cliq: @cliq,
      user: @user,
      post_type: :discussion
    )

    patch soft_delete_post_url(disposable.id)
    disposable.reload
    assert disposable.deleted?
    assert_redirected_to post_id_slug_post_url(post_id: disposable.id, slug: disposable.slug)
  end
end
