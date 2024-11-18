require "application_system_test_case"

class CliqsTest < ApplicationSystemTestCase
  setup do
    @cliq = cliqs(:one)
  end

  test "visiting the index" do
    visit cliqs_url
    assert_selector "h1", text: "Cliqs"
  end

  test "should create cliq" do
    visit cliqs_url
    click_on "New cliq"

    click_on "Create Cliq"

    assert_text "Cliq was successfully created"
    click_on "Back"
  end

  test "should update Cliq" do
    visit cliq_url(@cliq)
    click_on "Edit this cliq", match: :first

    click_on "Update Cliq"

    assert_text "Cliq was successfully updated"
    click_on "Back"
  end

  test "should destroy Cliq" do
    visit cliq_url(@cliq)
    click_on "Destroy this cliq", match: :first

    assert_text "Cliq was successfully destroyed"
  end
end
