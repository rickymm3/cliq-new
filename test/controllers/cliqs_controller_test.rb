require "test_helper"

class CliqsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cliq = cliqs(:one)
  end

  test "should get index" do
    get cliqs_url
    assert_response :success
  end

  test "should get new" do
    get new_cliq_url
    assert_response :success
  end

  test "should create cliq" do
    assert_difference("Cliq.count") do
      post cliqs_url, params: { cliq: {  } }
    end

    assert_redirected_to cliq_url(Cliq.last)
  end

  test "should show cliq" do
    get cliq_url(@cliq)
    assert_response :success
  end

  test "should get edit" do
    get edit_cliq_url(@cliq)
    assert_response :success
  end

  test "should update cliq" do
    patch cliq_url(@cliq), params: { cliq: {  } }
    assert_redirected_to cliq_url(@cliq)
  end

  test "should destroy cliq" do
    assert_difference("Cliq.count", -1) do
      delete cliq_url(@cliq)
    end

    assert_redirected_to cliqs_url
  end
end
