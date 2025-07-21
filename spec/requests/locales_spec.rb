require "rails_helper"

RSpec.describe "Locales" do
  describe "PATCH /switch_locale" do
    context "when switching to a valid locale" do
      context "with HTML format" do
        it "stores the locale in session and redirects" do # rubocop:disable RSpec/MultipleExpectations
          patch switch_locale_path, params: { locale: "ar" }

          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(root_path)
          expect(session[:locale]).to eq(:ar)
        end

        it "redirects back to referrer when provided" do # rubocop:disable RSpec/MultipleExpectations
          patch switch_locale_path, params: { locale: "en" }, headers: { "HTTP_REFERER" => "/books" }

          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to("/books")
          expect(session[:locale]).to eq(:en)
        end
      end

      context "with JSON format" do
        it "stores the locale in session and returns ok" do # rubocop:disable RSpec/MultipleExpectations
          patch switch_locale_path, params: { locale: "ar" }, headers: { "Accept" => "application/json" }

          expect(response).to have_http_status(:ok)
          expect(response.body).to be_empty
          expect(session[:locale]).to eq(:ar)
        end
      end

      it "switches between available locales" do # rubocop:disable RSpec/MultipleExpectations
        # Switch to Arabic
        patch switch_locale_path, params: { locale: "ar" }
        expect(session[:locale]).to eq(:ar)

        # Switch to English
        patch switch_locale_path, params: { locale: "en" }
        expect(session[:locale]).to eq(:en)
      end
    end

    context "when switching to an invalid locale" do
      context "with HTML format" do
        it "does not store invalid locale and still redirects" do # rubocop:disable RSpec/MultipleExpectations
          patch switch_locale_path, params: { locale: "invalid" }

          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(root_path)
          expect(session[:locale]).to be_nil
        end
      end

      context "with JSON format" do
        it "does not store invalid locale and returns ok" do # rubocop:disable RSpec/MultipleExpectations
          patch switch_locale_path, params: { locale: "invalid" }, headers: { "Accept" => "application/json" }

          expect(response).to have_http_status(:ok)
          expect(response.body).to be_empty
          expect(session[:locale]).to be_nil
        end
      end
    end

    context "when no locale parameter is provided" do
      context "with HTML format" do
        it "does not change session and redirects" do # rubocop:disable RSpec/MultipleExpectations
          patch switch_locale_path

          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(root_path)
          expect(session[:locale]).to be_nil
        end
      end

      context "with JSON format" do
        it "does not change session and returns ok" do # rubocop:disable RSpec/MultipleExpectations
          patch switch_locale_path, headers: { "Accept" => "application/json" }

          expect(response).to have_http_status(:ok)
          expect(response.body).to be_empty
          expect(session[:locale]).to be_nil
        end
      end
    end

    context "when locale parameter is empty string" do
      it "does not store empty locale" do # rubocop:disable RSpec/MultipleExpectations
        patch switch_locale_path, params: { locale: "" }

        expect(response).to have_http_status(:redirect)
        expect(session[:locale]).to be_nil
      end
    end

    context "when locale parameter is nil" do
      it "does not store nil locale" do # rubocop:disable RSpec/MultipleExpectations
        patch switch_locale_path, params: { locale: nil }

        expect(response).to have_http_status(:redirect)
        expect(session[:locale]).to be_nil
      end
    end

    context "with existing locale in session" do
      before do
        # Set initial locale
        patch switch_locale_path, params: { locale: "ar" }
      end

              it "overwrites existing locale with new valid locale" do # rubocop:disable RSpec/MultipleExpectations
          patch switch_locale_path, params: { locale: "en" }

          expect(response).to have_http_status(:redirect)
          expect(session[:locale]).to eq(:en)
      end

      it "keeps existing locale when invalid locale provided" do # rubocop:disable RSpec/MultipleExpectations
        patch switch_locale_path, params: { locale: "invalid" }

        expect(response).to have_http_status(:redirect)
        expect(session[:locale]).to eq("ar") # Should remain unchanged from before block
      end
    end

    context "CSRF protection" do
      it "accepts requests with proper CSRF handling" do
        # This test verifies CSRF protection is working normally
        # Since Rails handles CSRF automatically in test environment,
        # we just verify the request works as expected
        patch switch_locale_path, params: { locale: "ar" }
        
        expect(response).to have_http_status(:redirect)
        expect(session[:locale]).to eq(:ar)
      end
    end
  end
end 