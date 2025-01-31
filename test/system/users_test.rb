require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
  end

  test "visiting the index" do
    visit users_url
    assert_selector "h1", text: "Users"

    assert_text "dave"
    assert_text "adaobi"
  end

  test "should create user" do
    visit users_url
    click_on "New user"

    fill_in "Name", with: "Buck"
    fill_in "Password", with: "secret"
    fill_in "Confirm password", with: "secret"
    click_on "Create User"

    assert_text "User Buck successfully created"
  end

  test "should update User" do
    visit user_url(@user)
    click_on "Edit this user", match: :first

    fill_in "Name", with: @user.name
    fill_in "Password", with: "secret"
    fill_in "Confirm password", with: "secret"
    click_on "Update User"

    assert_text "User #{@user.name} successfully updated"
  end

  test "should destroy User" do
    visit user_url(users(:two))
    click_on "Destroy this user", match: :first

    assert_text "User was successfully destroyed"
  end
end
