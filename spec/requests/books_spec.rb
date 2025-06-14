require 'rails_helper'

RSpec.describe "Books" do
  describe "GET /show" do
    let(:book) { create(:book, :with_files) }

    it "redirects to the first page" do
      get "/books/#{book.id}"

      expect(response).to redirect_to(book_file_page_path(book, book.pages.first.file, book.pages.first))
    end
  end
end
