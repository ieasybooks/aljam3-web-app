# == Schema Information
#
# Table name: books
#
#  id          :bigint           not null, primary key
#  author      :string           not null
#  category    :string           not null
#  files_count :integer          default(0), not null
#  pages       :integer          not null
#  title       :string           not null
#  volumes     :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  library_id  :bigint           not null
#
# Indexes
#
#  index_books_on_library_id  (library_id)
#
# Foreign Keys
#
#  fk_rails_...  (library_id => libraries.id)
#
require "rails_helper"

RSpec.describe Book do
  describe "associations" do
    it { is_expected.to belong_to(:library).counter_cache(true) }
    it { is_expected.to have_many(:files).class_name("BookFile").dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:author) }
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:volumes) }
    it { is_expected.to validate_presence_of(:pages) }
  end

  describe "#first_page" do
    it "returns the first page of the first file" do
      book = create(:book, :with_files, files_count: 3)

      expect(book.first_page).to eq(book.files.first.pages.first) # rubocop:disable RSpec/MultipleExpectations
    end
  end

  describe "Meilisearch configuration" do
    before do
      described_class.index.number_of_documents
    end

    it 'includes Meilisearch::Rails' do
      expect(described_class.included_modules).to include(Meilisearch::Rails)
    end

    it 'has the correct searchable attributes' do
      expect(described_class.index.searchable_attributes).to match_array(%w[title])
    end

    it 'has the correct filterable attributes' do
      expect(described_class.index.filterable_attributes).to match_array(%w[category author library])
    end
  end

  describe "factory" do
    it "has a valid factory" do
      expect(create(:book)).to be_valid
    end

    it "has a valid factory with files" do # rubocop:disable RSpec/MultipleExpectations
      book = create(:book, :with_files, files_count: 3)

      expect(book.library).to eq(Library.first)
      expect(book.files.count).to eq(book.volumes)
      expect(book.files.map { it.pages.count }.sum).to eq(book.pages)
    end
  end
end
