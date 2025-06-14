require 'rails_helper'

RSpec.describe "Pages" do
  describe "GET /show" do
    let(:page) { create(:page) }

    it "returns http success" do
      get "/books/#{page.file.book.id}/files/#{page.file.id}/pages/#{page.number}"

      expect(response).to have_http_status(:success)
    end
  end
end
