require "test_helper"

class BookFilesTest < ApplicationTest
  test "redirects to the first page" do
    file = create(:book_file, :with_pages)

    get book_file_path(book_id: file.book.id, file_id: file.id)

    assert_redirected_to book_file_page_path(book_id: file.book.id, file_id: file.id, page_number: file.pages.first.number)
  end
end
