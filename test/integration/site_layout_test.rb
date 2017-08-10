require "test_helper"

class SiteLayoutTest < ActionDispatch::IntegrationTest
  def setup
    @user = users :michael
  end

  test "layout links" do
    get root_path # non logged in
    assert_template "static_pages/home"
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", login_path # users
    get contact_path
    assert_select "title", full_title("Contact")
    get signup_path
    assert_select "title", full_title("Sign up")
    log_in_as @user
    get root_path # logged-in
    assert_template "static_pages/home"
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", users_path # users
    assert_select "a[href=?]", logout_path # logout
    assert_select "a[href=?]", user_path(@user) # prolfile
    assert_select "a[href=?]", edit_user_path(@user) # settings
  end
end
