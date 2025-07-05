# == Schema Information
#
# Table name: authors
#
#  id          :bigint           not null, primary key
#  books_count :integer          default(0), not null
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require "rails_helper"

RSpec.describe Author do
  describe "associations" do
    it { is_expected.to have_many(:books).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "Meilisearch configuration" do
    before do
      described_class.index.number_of_documents
    end

    it 'includes Meilisearch::Rails' do
      expect(described_class.included_modules).to include(Meilisearch::Rails)
    end

    it 'has the correct searchable attributes' do
      expect(described_class.index.searchable_attributes).to match_array(%w[name])
    end
  end
end
