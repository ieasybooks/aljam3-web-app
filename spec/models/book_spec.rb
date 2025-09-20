# == Schema Information
#
# Table name: books
#
#  id          :bigint           not null, primary key
#  files_count :integer          default(0), not null
#  hidden      :boolean          default(FALSE), not null
#  pages_count :integer          not null
#  title       :string           not null
#  views_count :integer          default(0), not null
#  volumes     :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  author_id   :bigint           not null
#  category_id :bigint           not null
#  library_id  :bigint           not null
#
# Indexes
#
#  index_books_on_author_id    (author_id)
#  index_books_on_category_id  (category_id)
#  index_books_on_library_id   (library_id)
#  index_books_on_views_count  (views_count)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => authors.id)
#  fk_rails_...  (category_id => categories.id)
#  fk_rails_...  (library_id => libraries.id)
#
require "rails_helper"

RSpec.describe Book do
  describe "associations" do
    it { is_expected.to belong_to(:library).counter_cache(true) }
    it { is_expected.to belong_to(:author).counter_cache(true) }
    it { is_expected.to belong_to(:category).counter_cache(true) }
    it { is_expected.to have_many(:files).class_name("BookFile").dependent(:destroy) }
    it { is_expected.to have_many(:pages).through(:files) }
    it { is_expected.to have_many(:search_clicks).dependent(:delete_all) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:volumes) }
    it { is_expected.to validate_presence_of(:pages_count) }
  end

  describe "Meilisearch configuration" do
    before do
      described_class.index.number_of_documents
    end

    it "includes Meilisearch::Rails" do
      expect(described_class.included_modules).to include(Meilisearch::Rails)
    end

    it "has the correct searchable attributes" do
      expect(described_class.index.searchable_attributes).to match_array(%w[title])
    end

    it "has the correct filterable attributes" do
      expect(described_class.index.filterable_attributes).to match_array(%w[id library author category hidden])
    end
  end

  describe "#increment_views!" do
    it "increments the views count by 1" do
      book = create(:book, views_count: 5)

      expect { book.increment_views! }.to change { book.reload.views_count }.from(5).to(6)
    end
  end

  describe ".most_viewed" do
    it "returns books ordered by views_count descending" do
      book_10 = create(:book, views_count: 10)
      book_5 = create(:book, views_count: 5)
      book_8 = create(:book, views_count: 8)

      expect(described_class.most_viewed).to eq([ book_10, book_8, book_5 ])
    end

    it "excludes hidden books" do
      create(:book, views_count: 10, hidden: true)
      book_5 = create(:book, views_count: 5)
      book_8 = create(:book, views_count: 8)

      expect(described_class.most_viewed).to eq([ book_8, book_5 ])
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
      expect(book.files.map { it.pages.count }.sum).to eq(book.pages_count)
    end
  end
end
