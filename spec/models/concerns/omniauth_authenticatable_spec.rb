require "rails_helper"

RSpec.describe OmniauthAuthenticatable do
  describe ".from_omniauth" do
    let(:provider) { "google_oauth2" }
    let(:uid) { "1234567890" }
    let(:email) { "oauth-user@example.com" }
    let(:auth_info) { double(email: email) } # rubocop:disable RSpec/VerifiedDoubles
    let(:auth) { double(provider: provider, uid: uid, info: auth_info) } # rubocop:disable RSpec/VerifiedDoubles

    context "when the user does not exist" do
      it "creates a confirmed user with provider and uid" do # rubocop:disable RSpec/MultipleExpectations
        expect { User.from_omniauth(auth) }.to change(User, :count).by(1)

        user = User.find_by(email: email)

        expect(user.provider).to eq(provider)
        expect(user.uid).to eq(uid)
        expect(user).to be_confirmed
      end
    end

    context "when the user exists without provider and is unconfirmed" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let!(:user) { create(:user, email: email, confirmed_at: nil, provider: nil, uid: nil) }

      it "does not create a new user, sets provider/uid and confirms the user" do # rubocop:disable RSpec/MultipleExpectations
        expect { User.from_omniauth(auth) }.not_to change(User, :count)

        user.reload

        expect(user.provider).to eq(provider)
        expect(user.uid).to eq(uid)
        expect(user).to be_confirmed
      end
    end

    context "when the user exists with provider/uid present and is unconfirmed" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let!(:user) { create(:user, email: email, confirmed_at: nil, provider: "existing_provider", uid: "existing_uid") }

      it "does not overwrite provider/uid but confirms the user" do # rubocop:disable RSpec/MultipleExpectations
        User.from_omniauth(auth)

        user.reload

        expect(user.provider).to eq("existing_provider")
        expect(user.uid).to eq("existing_uid")
        expect(user).to be_confirmed
      end
    end

    context "when the user exists with provider/uid present and is already confirmed" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let!(:user) { create(:user, email: email, provider: "existing_provider", uid: "existing_uid") }

      it "returns the user without modifying provider/uid or confirmation" do # rubocop:disable RSpec/MultipleExpectations
        User.from_omniauth(auth)

        user.reload

        expect(user.provider).to eq("existing_provider")
        expect(user.uid).to eq("existing_uid")
        expect(user).to be_confirmed
      end
    end
  end
end
