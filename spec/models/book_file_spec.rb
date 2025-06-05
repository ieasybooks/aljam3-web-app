# == Schema Information
#
# Table name: book_files
#
#  id         :bigint           not null, primary key
#  file_type  :integer          not null
#  size       :float            not null
#  url        :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :bigint           not null
#
# Indexes
#
#  index_book_files_on_book_id  (book_id)
#
# Foreign Keys
#
#  fk_rails_...  (book_id => books.id)
#
require 'rails_helper'

RSpec.describe BookFile do
  describe "associations" do
    it { is_expected.to belong_to(:book) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:file_type) }
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_presence_of(:size) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:file_type).with_values(pdf: 0, txt: 1, docx: 2) }
  end

  describe "factory" do
    it "has a valid factory" do
      expect(create(:book_file)).to be_valid
    end

    it "has a valid PDF book_file factory with pages" do # rubocop:disable RSpec/MultipleExpectations
      book_file = create(:book_file, :pdf, :with_pages, pages_count: 5)

      expect(book_file.book.library).to eq(Library.first)
      expect(book_file.book).to eq(Book.first)
      expect(book_file.pages.count).to eq(0)
    end

    it "has a valid TXT book_file factory with pages" do # rubocop:disable RSpec/MultipleExpectations
      book_file = create(:book_file, :txt, :with_pages, pages_count: 5)

      expect(book_file.book.library).to eq(Library.first)
      expect(book_file.book).to eq(Book.first)
      expect(book_file.pages.count).to eq(5)
    end

    it "has a valid DOCX book_file factory with pages" do # rubocop:disable RSpec/MultipleExpectations
      book_file = create(:book_file, :docx, :with_pages, pages_count: 5)

      expect(book_file.book.library).to eq(Library.first)
      expect(book_file.book).to eq(Book.first)
      expect(book_file.pages.count).to eq(0)
    end
  end
end
