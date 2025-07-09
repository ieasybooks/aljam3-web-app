require 'rails_helper'

RSpec.describe "Books" do
  describe "GET /show" do
    let(:book) { create(:book, :with_files) }

    it "redirects to the first page" do
      get book_path(book.id)

      expect(response).to redirect_to(book_file_page_path(book.id, book.pages.first.file.id, book.pages.first.number))
    end
  end
end
