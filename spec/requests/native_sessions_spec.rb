require "rails_helper"

RSpec.describe "Native sessions", :aggregate_failures do
  let(:user) { create(:user) }
  let(:native_headers) { { "User-Agent" => "Hotwire Native iOS" } }
  let(:invalid_tokens) { [ "invalid", user.signed_id(purpose: "native_handoff", expires_in: -1.second), user.signed_id(purpose: "other") ] }

  it "returns the native navigation configuration" do
    get "/hotwire/ios/path_configuration"
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig("settings", "tabs").pluck("path")).to eq(%w[/ /categories /authors /books])
  end

  it "signs in through the native form and resets the native screen" do
    post user_session_path, params: { user: { email: user.email, password: "password" } }, headers: native_headers
    expect(response).to redirect_to("/reset_app")
    expect(request.env["warden"].user).to eq(user)
  end

  context "with a valid handoff token" do
    before do
      token = user.signed_id(purpose: "native_handoff", expires_in: 30.seconds)
      get "/native/session/handoff", params: { token: }, headers: native_headers
    end

    it "establishes the session and resets the native screen" do
      expect(response).to redirect_to("/reset_app")
      expect(request.env["warden"].user).to eq(user)
    end

    it "renders the reset page with its JavaScript" do
      follow_redirect!
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<script")
    end
  end

  it "rejects tampered, expired, and wrong-purpose handoff tokens" do
    invalid_tokens.each do |token|
      get "/native/session/handoff", params: { token: }, headers: native_headers
      expect(response).to have_http_status(:unauthorized)
      expect(request.env["warden"].user).to be_nil
    end
  end

  it "keeps the home page anonymous when its sign-in token is invalid" do
    get root_path, params: { sign_in_token: "invalid" }
    expect(response).to have_http_status(:ok)
    expect(request.env["warden"].user).to be_nil
  end

  it "signs out the authenticated API session" do
    sign_in user
    delete "/api/v1/auth"
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq({})
    expect(request.env["warden"].user).to be_nil
  end
end
