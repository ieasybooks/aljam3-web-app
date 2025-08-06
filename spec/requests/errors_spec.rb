require 'rails_helper'

RSpec.describe "Errors" do
  describe "GET /404" do
    it "returns http not found" do
      get "/404"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /422" do
    it "returns http unprocessable content" do
      get "/422"
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /500" do
    it "returns http internal server error" do
      get "/500"
      expect(response).to have_http_status(:internal_server_error)
    end
  end

  describe "GET /406" do
    it "returns http not acceptable" do
      get "/406"
      expect(response).to have_http_status(:not_acceptable)
    end
  end

  describe "GET /400" do
    it "returns http bad request" do
      get "/400"
      expect(response).to have_http_status(:bad_request)
    end
  end
end
