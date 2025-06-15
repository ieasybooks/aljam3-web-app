require "rails_helper"

RSpec.describe "RackMiniProfiler" do
  describe "check_rack_mini_profiler" do
    let(:user) { double }

    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user) # rubocop:disable RSpec/AnyInstance
    end

    context "when user is not admin" do
      it "does not authorize the request" do
        allow(Rack::MiniProfiler).to receive(:authorize_request)
        allow(user).to receive(:admin?).and_return(false)

        get "/"

        expect(Rack::MiniProfiler).not_to have_received(:authorize_request)
      end
    end

    context "when user is admin" do
      it "authorizes the request" do
        allow(Rack::MiniProfiler).to receive(:authorize_request)
        allow(user).to receive(:admin?).and_return(true)

        get "/"

        expect(Rack::MiniProfiler).to have_received(:authorize_request)
      end
    end
  end
end
