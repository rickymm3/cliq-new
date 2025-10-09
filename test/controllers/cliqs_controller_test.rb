require "test_helper"
require "securerandom"

class CliqsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @root_cliq = cliqs(:root_cliq)
    @cliq = cliqs(:child_cliq)
    @user = users(:alice)
  end

  test "should get index" do
    get cliqs_url
    assert_response :success
  end

  test "guest is redirected when visiting new" do
    get new_cliq_url
    assert_redirected_to new_user_session_url
  end

  test "authenticated user can access new" do
    sign_in @user
    get new_cliq_url
    assert_response :success
  end

  test "should create cliq for authenticated user" do
    sign_in @user
    assert_difference("Cliq.count", 1) do
      post cliqs_url, params: {
        cliq: {
          name: "Testing #{SecureRandom.hex(3)}",
          description: "Test description",
          parent_cliq_id: @root_cliq.id
        }
      }
    end
    assert_redirected_to cliq_url(Cliq.last)
  end

  test "should show cliq" do
    get cliq_url(@cliq)
    assert_response :success
  end

  test "should get edit for authenticated user" do
    sign_in @user
    get edit_cliq_url(@cliq)
    assert_response :success
  end

  test "should update cliq" do
    sign_in @user
    patch cliq_url(@cliq), params: { cliq: { description: "Updated description" } }
    assert_redirected_to cliqs_url
    assert_equal "Updated description", @cliq.reload.description
  end

  test "should destroy cliq" do
    sign_in @user
    disposable = Cliq.create!(name: "Disposable #{SecureRandom.hex(3)}", parent_cliq: @root_cliq)
    assert_difference("Cliq.count", -1) do
      delete cliq_url(disposable)
    end

    assert_redirected_to cliqs_url
  end
end
