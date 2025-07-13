# == Schema Information
#
# Table name: book_files
#
#  id          :bigint           not null, primary key
#  docx_url    :text             default(""), not null
#  pages_count :integer          default(0), not null
#  pdf_url     :text             default(""), not null
#  txt_url     :text             default(""), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  book_id     :bigint           not null
#
# Indexes
#
#  index_book_files_on_book_id  (book_id)
#
# Foreign Keys
#
#  fk_rails_...  (book_id => books.id)
#
require "rails_helper"

RSpec.describe BookFile do
  describe "associations" do
    it { is_expected.to belong_to(:book).counter_cache(:files_count) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:pdf_url) }
    it { is_expected.to validate_presence_of(:txt_url) }
    it { is_expected.to validate_presence_of(:docx_url) }
  end

  describe "name" do
    it "returns the name of the file" do
      book_file = create(:book_file, pdf_url: "https://example.com/file.pdf")

      expect(book_file.name).to eq("file")
    end

    it "returns the name of the file with the correct encoding" do
      book_file = create(:book_file, pdf_url: "https://example.com/%D8%A7%D9%84%D9%83%D8%AA%D8%A7%D8%A8.pdf")

      expect(book_file.name).to eq("الكتاب")
    end
  end

  describe "factory" do
    it "has a valid factory" do # rubocop:disable RSpec/MultipleExpectations
      book_file = create(:book_file)

      expect(book_file).to be_valid
      expect(book_file.book.library).to eq(Library.first)
      expect(book_file.book).to eq(Book.first)
      expect(book_file.pages.count).to eq(0)
    end

    it "has a valid book_file factory with pages" do # rubocop:disable RSpec/MultipleExpectations
      book_file = create(:book_file, :with_pages, pages_count: 5)

      expect(book_file.pages.count).to eq(5)
    end
  end
end
