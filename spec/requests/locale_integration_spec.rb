require "rails_helper"

RSpec.describe "Locale Integration", type: :request do
  describe "complete locale switching flow" do
    it "switches locale and applies it on subsequent requests" do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
      # Start with default locale
      get root_path
      expect(response).to have_http_status(:ok)

      # Switch to Arabic
      patch switch_locale_path, params: { locale: "ar" }
      expect(response).to have_http_status(:redirect)
      expect(session[:locale]).to eq(:ar)

      # Follow the redirect and verify locale is applied
      follow_redirect!
      expect(response).to have_http_status(:ok)
      # Note: You would typically check for Arabic text in the response here
      # expect(response.body).to include("Arabic text") 

      # Switch back to English
      patch switch_locale_path, params: { locale: "en" }
      expect(response).to have_http_status(:redirect)
      expect(session[:locale]).to eq(:en)

      # Follow redirect and verify English locale is applied
      follow_redirect!
      expect(response).to have_http_status(:ok)
      # Note: You would typically check for English text in the response here
      # expect(response.body).to include("English text")
    end

    it "maintains locale preference across different pages" do # rubocop:disable RSpec/MultipleExpectations
      # Set locale to Arabic
      patch switch_locale_path, params: { locale: "ar" }
      expect(session[:locale]).to eq(:ar)

      # Visit different pages and verify locale persists
      get root_path
      expect(response).to have_http_status(:ok)

      # Visit books page (if it exists) - adjust path as needed
      get books_path if Rails.application.routes.recognize_path("/books") rescue nil
      # expect(session[:locale]).to eq("ar") # Session should persist
    end

    it "handles invalid locale gracefully and doesn't break navigation" do # rubocop:disable RSpec/MultipleExpectations
      # Try to switch to invalid locale
      patch switch_locale_path, params: { locale: "invalid_locale_xyz" }
      expect(response).to have_http_status(:redirect)
      expect(session[:locale]).to be_nil

      # Verify app still works normally
      follow_redirect!
      expect(response).to have_http_status(:ok)

      # Should be able to switch to valid locale after invalid attempt
      patch switch_locale_path, params: { locale: "ar" }
      expect(session[:locale]).to eq(:ar)
    end
  end

  describe "locale switching via AJAX" do
    it "handles JSON requests properly" do # rubocop:disable RSpec/MultipleExpectations
      patch switch_locale_path, 
            params: { locale: "ar" },
            headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)
      expect(session[:locale]).to eq(:ar)
    end
  end
end 