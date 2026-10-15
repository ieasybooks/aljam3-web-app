require "test_helper"

class BookFileTest < ModelTest
  test "has the expected association and URL validations" do
    assert_model_matcher(belong_to(:book).counter_cache(:files_count), BookFile)
    assert_model_matcher(validate_presence_of(:pdf_url), BookFile)
    assert_model_matcher(validate_presence_of(:txt_url), BookFile)
    assert_model_matcher(validate_presence_of(:docx_url), BookFile)
  end

  test "returns the file name from its PDF URL" do
    assert_equal "file", create(:book_file, pdf_url: "https://example.com/file.pdf").name
  end

  test "decodes non-ASCII file names" do
    book_file = create(:book_file, pdf_url: "https://example.com/%D8%A7%D9%84%D9%83%D8%AA%D8%A7%D8%A8.pdf")

    assert_equal "الكتاب", book_file.name
  end
end
