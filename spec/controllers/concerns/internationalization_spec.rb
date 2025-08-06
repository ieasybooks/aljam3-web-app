require "rails_helper"

RSpec.describe "Internationalization" do
  controller(ActionController::Base) do
    include Internationalization

    def index = render plain: "Locale: #{I18n.locale}"
  end

  before do
    I18n.available_locales = [ :en, :fr, :de ]
    I18n.default_locale = :en

    routes.draw { get "index" => "anonymous#index" }
  end

  describe "locale selection" do
    context "with locale in URL param" do
      it "sets locale from URL and updates cookie and header" do # rubocop:disable RSpec/MultipleExpectations
        get :index, params: { locale: "fr" }

        expect(response.body).to include("Locale: fr")
        expect(cookies[:locale]).to eq("fr")
        expect(response.headers["Content-Language"]).to eq("fr")
      end

      it "ignores invalid locale in URL param" do # rubocop:disable RSpec/MultipleExpectations
        get :index, params: { locale: "es" }

        expect(response.body).to include("Locale: en")
        expect(cookies[:locale]).to eq("en")
        expect(response.headers["Content-Language"]).to eq(:en)
      end
    end

    context "with locale in cookies" do
      it "sets locale from cookie if no URL param" do # rubocop:disable RSpec/MultipleExpectations
        request.cookies[:locale] = "de"
        get :index

        expect(response.body).to include("Locale: de")
        expect(cookies[:locale]).to eq("de")
        expect(response.headers["Content-Language"]).to eq("de")
      end

      it "ignores invalid locale in cookie" do # rubocop:disable RSpec/MultipleExpectations
        request.cookies[:locale] = "jp"
        get :index

        expect(response.body).to include("Locale: en")
        expect(cookies[:locale]).to eq("en")
        expect(response.headers["Content-Language"]).to eq(:en)
      end
    end

    context "with locale in Accept-Language header" do
      it "parses and selects supported locale" do # rubocop:disable RSpec/MultipleExpectations
        request.headers["HTTP_ACCEPT_LANGUAGE"] = "fr-CH,fr;q=0.9,en;q=0.8"
        get :index

        expect(response.body).to include("Locale: fr")
        expect(cookies[:locale]).to eq("fr")
        expect(response.headers["Content-Language"]).to eq("fr")
      end

      it "ignores unsupported Accept-Language header" do # rubocop:disable RSpec/MultipleExpectations
        request.headers["HTTP_ACCEPT_LANGUAGE"] = "es-MX,es;q=0.9"
        get :index

        expect(response.body).to include("Locale: en")
        expect(cookies[:locale]).to eq("en")
        expect(response.headers["Content-Language"]).to eq(:en)
      end

      it "ignores empty Accept-Language header" do # rubocop:disable RSpec/MultipleExpectations
        request.headers["HTTP_ACCEPT_LANGUAGE"] = ""
        get :index

        expect(response.body).to include("Locale: en")
        expect(cookies[:locale]).to eq("en")
        expect(response.headers["Content-Language"]).to eq(:en)
      end
    end

    context "with nothing provided" do
      it "falls back to default locale" do # rubocop:disable RSpec/MultipleExpectations
        get :index

        expect(response.body).to include("Locale: en")
        expect(cookies[:locale]).to eq("en")
        expect(response.headers["Content-Language"]).to eq(:en)
      end
    end
  end
end
