require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  include Devise::Test::ControllerHelpers
  controller do
    def index
      render json: { locale: I18n.locale.to_s, default_locale: I18n.default_locale.to_s }
    end
  end

  before do
    routes.draw { get "index" => "anonymous#index" }
  end

  describe "locale management" do
    describe "#set_locale" do
      context "when session has no locale" do
        it "sets locale to default locale" do
          get :index

          json_response = JSON.parse(response.body)
          expect(json_response["locale"]).to eq(I18n.default_locale.to_s)
        end
      end

      context "when session has a valid locale" do
        before do
          session[:locale] = "ar"
        end

        it "sets locale to session locale" do
          get :index

          json_response = JSON.parse(response.body)
          expect(json_response["locale"]).to eq("ar")
        end
      end

      context "when session has an invalid locale" do
        before do
          session[:locale] = "invalid"
        end

        it "raises I18n::InvalidLocale error" do
          # I18n.locale= validates locales and raises error for invalid ones
          expect { get :index }.to raise_error(I18n::InvalidLocale)
        end
      end

      context "when session locale is nil" do
        before do
          session[:locale] = nil
        end

        it "falls back to default locale" do
          get :index

          json_response = JSON.parse(response.body)
          expect(json_response["locale"]).to eq(I18n.default_locale.to_s)
        end
      end

      context "when session locale is empty string" do
        before do
          session[:locale] = ""
        end

        it "raises I18n::InvalidLocale error for empty string" do
          # I18n.locale= validates locales and raises error for empty string
          expect { get :index }.to raise_error(I18n::InvalidLocale)
        end
      end
    end

    describe "locale persistence across requests" do
      it "maintains locale across multiple requests when set in session" do # rubocop:disable RSpec/MultipleExpectations
        # First request with session locale
        session[:locale] = "ar"
        get :index
        json_response = JSON.parse(response.body)
        expect(json_response["locale"]).to eq("ar")

        # Second request should maintain the locale
        get :index
        json_response = JSON.parse(response.body)
        expect(json_response["locale"]).to eq("ar")
      end
    end
  end
end 