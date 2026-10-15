require "test_helper"

class UsersOmniauthCallbacksControllerTest < ApplicationTest
  setup do
    @user = create(:user, email: "test@example.com")
    @auth_hash = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "123456",
      info: { email: "test@example.com", first_name: "Test", last_name: "User" }
    )
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = @auth_hash
    Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
    Rails.application.env_config["omniauth.auth"] = @auth_hash
  end

  teardown do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    Rails.application.env_config["devise.mapping"] = nil
    Rails.application.env_config["omniauth.auth"] = nil
  end

  test "signs in the user" do
    User.stubs(:from_omniauth).returns(@user)

    get "/users/auth/google_oauth2/callback"

    assert_redirected_to root_path
    assert_equal I18n.t("devise.omniauth_callbacks.success", kind: "Google"), flash[:notice]
  end

  test "does not set a notice for a non-navigational format" do
    User.stubs(:from_omniauth).returns(@user)
    Users::OmniauthCallbacksController.any_instance.stubs(:is_navigational_format?).returns(false)

    get "/users/auth/google_oauth2/callback"

    assert_redirected_to root_path
    assert_nil flash[:notice]
  end

  test "creates a new user when one does not exist" do
    Users::OmniauthCallbacksController.any_instance.stubs(:auth).returns(@auth_hash)
    @auth_hash.info.email = "new-user@example.com"

    assert_difference("User.count", 1) do
      get "/users/auth/google_oauth2/callback"
    end
  end

  test "updates an existing user without creating another" do
    Users::OmniauthCallbacksController.any_instance.stubs(:auth).returns(@auth_hash)

    assert_no_difference("User.count") do
      get "/users/auth/google_oauth2/callback"
    end

    @user.reload
    assert_equal "google_oauth2", @user.provider
    assert_equal "123456", @user.uid
  end

  test "confirms an unconfirmed user" do
    user = @user
    user.update!(confirmed_at: nil)
    Users::OmniauthCallbacksController.any_instance.stubs(:auth).returns(@auth_hash)

    assert_changes -> { user.reload.confirmed? }, from: false, to: true do
      get "/users/auth/google_oauth2/callback"
    end
  end

  test "redirects to sign in when authentication fails" do
    Users::OmniauthCallbacksController.any_instance.stubs(:auth).returns(@auth_hash)
    User.stubs(:from_omniauth).returns(nil)

    get "/users/auth/google_oauth2/callback"

    assert_redirected_to new_user_session_path
    assert_includes flash[:alert], "Google"
  end

  test "hands off a signed token to a native app" do
    User.stubs(:from_omniauth).returns(@user)
    post "/users/auth/google_oauth2?native=1"
    follow_redirect!

    token = Rack::Utils.parse_query(URI.parse(response.location).query).fetch("sign_in_token")
    assert_equal @user, User.find_signed(token, purpose: "native_handoff")
  end
end
