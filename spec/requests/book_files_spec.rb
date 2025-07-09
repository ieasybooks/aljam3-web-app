require 'rails_helper'

RSpec.describe "BookFiles" do
  describe "GET /show" do
    let(:file) { create(:book_file, :with_pages) }

    it "redirects to the first page" do
      get book_file_path(file.book, file)

      expect(response).to redirect_to(book_file_page_path(file.book, file, file.pages.first.number))
    end
  end
end
