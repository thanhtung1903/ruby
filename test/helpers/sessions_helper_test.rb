require "test_helper"

class SessionsHelperTest < ActionView::TestCase
  # session is auto set by posting to the login path so test "remember" branch
  # of current_user method is diffcult in integration test, so it solution
  def setup # auto run before every test
    @user = users :michael
    remember @user
  end
  test "test login status with cookie when session is nil" do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  # test authenticated?
  test "current_user returns nil when remember digest is wrong" do
    # the first step change remember_digest in DB
    @user.update_attributes remember_digest: User.digest(User.new_token)
    assert_nil current_user
  end
end
