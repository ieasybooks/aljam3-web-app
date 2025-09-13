require "rails_helper"

RSpec.describe Users::OmniauthCallbacksController do
  describe "GET /users/auth/google_oauth2/callback" do
    let(:user) { create(:user, email: "test@example.com") }

    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "123456",
        info: {
          email: "test@example.com",
          first_name: "Test",
          last_name: "User"
        }
      )
    end

    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:google_oauth2] = auth_hash
      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
      Rails.application.env_config["omniauth.auth"] = auth_hash
    end

    after do
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth[:google_oauth2] = nil
      Rails.application.env_config["devise.mapping"] = nil
      Rails.application.env_config["omniauth.auth"] = nil
    end

    context "when authentication is successful" do
      it "signs in the user" do # rubocop:disable RSpec/MultipleExpectations
        allow(User).to receive(:from_omniauth).and_return(user)

        get "/users/auth/google_oauth2/callback"

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t("devise.omniauth_callbacks.success", kind: "Google"))
      end

      it "does not set flash[:notice] when format is non-navigational" do # rubocop:disable RSpec/MultipleExpectations
        allow(User).to receive(:from_omniauth).and_return(user)
        allow_any_instance_of(described_class).to receive(:is_navigational_format?).and_return(false) # rubocop:disable RSpec/AnyInstance

        get "/users/auth/google_oauth2/callback"

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to be_nil
      end

      it "creates a new user if one does not exist" do
        expect do
          allow_any_instance_of(described_class).to receive(:auth).and_return(auth_hash) # rubocop:disable RSpec/AnyInstance
          allow(User).to receive(:from_omniauth).and_call_original

          get "/users/auth/google_oauth2/callback"
        end.to change(User, :count).by(1)
      end

      it "uses an existing user if one exists" do # rubocop:disable RSpec/MultipleExpectations
        user

        expect do
          allow_any_instance_of(described_class).to receive(:auth).and_return(auth_hash) # rubocop:disable RSpec/AnyInstance
          allow(User).to receive(:from_omniauth).and_call_original

          get "/users/auth/google_oauth2/callback"
        end.not_to change(User, :count)

        user.reload
        expect(user.provider).to eq("google_oauth2")
        expect(user.uid).to eq("123456")
      end

      it "confirms an unconfirmed user" do
        unconfirmed_user = create(:user, email: "test@example.com", confirmed_at: nil)

        allow_any_instance_of(described_class).to receive(:auth).and_return(auth_hash) # rubocop:disable RSpec/AnyInstance
        allow(User).to receive(:from_omniauth).and_call_original

        expect do
          get "/users/auth/google_oauth2/callback"
        end.to change { unconfirmed_user.reload.confirmed? }.from(false).to(true)
      end
    end

    context "when authentication fails" do
      it "redirects to sign in page with an error" do # rubocop:disable RSpec/MultipleExpectations
        allow_any_instance_of(described_class).to receive(:auth).and_return(auth_hash) # rubocop:disable RSpec/AnyInstance
        allow(User).to receive(:from_omniauth).and_return(nil)

        get "/users/auth/google_oauth2/callback"

        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to include("Google")
      end
    end
  end
end
