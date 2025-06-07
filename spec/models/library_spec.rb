# == Schema Information
#
# Table name: libraries
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Library do
  describe "associations" do
    it { is_expected.to have_many(:books).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "factory" do
    it "has a valid factory" do
      expect(create(:library)).to be_valid
    end

    it "has a valid factory with books" do # rubocop:disable RSpec/MultipleExpectations
      library = create(:library, :with_books, books_count: 3, deterministic_files_count: true)

      expect(library.books.count).to eq(3)
      expect(BookFile.count).to eq(library.books.pluck(:volumes).sum)
      expect(Page.count).to eq(library.books.pluck(:pages).sum)
    end
  end
end
