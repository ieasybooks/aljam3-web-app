require 'rails_helper'

RSpec.describe "Pages" do
  describe "GET /show" do
    let(:page) { create(:page) }

    it "returns http success" do
      get book_file_page_path(page.file.book.id, page.file.id, page.number)

      expect(response).to have_http_status(:success)
    end
  end
end
