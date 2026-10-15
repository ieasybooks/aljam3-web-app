require "test_helper"

class OmniauthAuthenticatableTest < ModelTest
  setup do
    @provider = "google_oauth2"
    @uid = "1234567890"
    @email = "oauth-user@example.com"
    @auth_info = mock("auth_info")
    @auth_info.stubs(:email).returns(@email)
    @auth = mock("auth")
    @auth.stubs(:provider).returns(@provider)
    @auth.stubs(:uid).returns(@uid)
    @auth.stubs(:info).returns(@auth_info)
  end

  test "creates a confirmed user when no matching user exists" do
    assert_difference("User.count", 1) do
      User.from_omniauth(@auth)
    end

    user = User.find_by!(email: @email)
    assert_equal @provider, user.provider
    assert_equal @uid, user.uid
    assert_predicate user, :confirmed?
  end

  test "updates an existing unconfirmed user without provider details" do
    user = create(:user, email: @email, confirmed_at: nil, provider: nil, uid: nil)

    assert_no_difference("User.count") do
      User.from_omniauth(@auth)
    end

    user.reload
    assert_equal @provider, user.provider
    assert_equal @uid, user.uid
    assert_predicate user, :confirmed?
  end

  test "confirms an existing user without overwriting provider details" do
    user = create(:user, email: @email, confirmed_at: nil, provider: "existing_provider", uid: "existing_uid")

    User.from_omniauth(@auth)

    user.reload
    assert_equal "existing_provider", user.provider
    assert_equal "existing_uid", user.uid
    assert_predicate user, :confirmed?
  end

  test "leaves an already confirmed user unchanged" do
    user = create(:user, email: @email, provider: "existing_provider", uid: "existing_uid")

    User.from_omniauth(@auth)

    user.reload
    assert_equal "existing_provider", user.provider
    assert_equal "existing_uid", user.uid
    assert_predicate user, :confirmed?
  end
end
