# == Schema Information
#
# Table name: pages
#
#  id           :bigint           not null, primary key
#  content      :text             not null
#  number       :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  book_file_id :bigint           not null
#
# Indexes
#
#  index_pages_on_book_file_id             (book_file_id)
#  index_pages_on_book_file_id_and_number  (book_file_id,number) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (book_file_id => book_files.id)
#
require 'rails_helper'

RSpec.describe Page do
  include Meilisearch::Rails

  describe "associations" do
    it { is_expected.to belong_to(:file).class_name("BookFile").counter_cache(true) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:content) }
  end

  describe "Meilisearch configuration" do
    before do
      described_class.index.number_of_documents
    end

    it 'includes Meilisearch::Rails' do
      expect(described_class.included_modules).to include(Meilisearch::Rails)
    end

    it 'has the correct searchable attributes' do
      expect(described_class.index.searchable_attributes).to match_array(%w[content])
    end

    it 'has the correct filterable attributes' do
      expect(described_class.index.filterable_attributes).to match_array(%w[category author book library])
    end
  end

  describe "factory" do
    it "has a valid factory" do # rubocop:disable RSpec/MultipleExpectations
      page = create(:page)

      expect(page).to be_valid

      expect(page.file.book.library).to eq(Library.first)
      expect(page.file.book).to eq(Book.first)
      expect(page.file).to eq(BookFile.first)
    end
  end
end
