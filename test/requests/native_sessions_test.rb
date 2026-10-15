require "test_helper"

class NativeSessionsTest < ApplicationTest
  setup do
    @user = create(:user)
    @native_headers = { "User-Agent" => "Hotwire Native iOS" }
  end

  test "returns the native navigation configuration" do
    get "/hotwire/ios/path_configuration"

    assert_response :ok
    assert_equal %w[/ /categories /authors /books], response.parsed_body.dig("settings", "tabs").pluck("path")
  end

  test "signs in through the native form and resets the native screen" do
    post user_session_path, params: { user: { email: @user.email, password: "password" } }, headers: @native_headers

    assert_redirected_to "/reset_app"
    assert_equal @user, request.env["warden"].user
  end

  test "establishes a session from a valid handoff token" do
    token = @user.signed_id(purpose: "native_handoff", expires_in: 30.seconds)

    get "/native/session/handoff", params: { token: }, headers: @native_headers

    assert_redirected_to "/reset_app"
    assert_equal @user, request.env["warden"].user
  end

  test "renders the reset page after a valid handoff" do
    token = @user.signed_id(purpose: "native_handoff", expires_in: 30.seconds)
    get "/native/session/handoff", params: { token: }, headers: @native_headers
    follow_redirect!

    assert_response :ok
    assert_includes response.body, "<script"
  end

  test "rejects invalid handoff tokens" do
    tokens = [
      "invalid",
      @user.signed_id(purpose: "native_handoff", expires_in: -1.second),
      @user.signed_id(purpose: "other")
    ]

    tokens.each do |token|
      get "/native/session/handoff", params: { token: }, headers: @native_headers
      assert_response :unauthorized
      assert_nil request.env["warden"].user
    end
  end

  test "keeps the home page anonymous when its sign-in token is invalid" do
    get root_path, params: { sign_in_token: "invalid" }

    assert_response :ok
    assert_nil request.env["warden"].user
  end

  test "signs out the authenticated API session" do
    sign_in @user

    delete "/api/v1/auth"

    assert_response :ok
    assert_equal({}, response.parsed_body)
    assert_nil request.env["warden"].user
  end
end
