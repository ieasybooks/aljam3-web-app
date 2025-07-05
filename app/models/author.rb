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
class Author < ApplicationRecord
  include Meilisearch::Rails

  extend Pagy::Meilisearch
  ActiveRecord_Relation.include Pagy::Meilisearch

  has_many :books, dependent: :destroy

  validates :name, presence: true

  meilisearch enqueue: true do
    attribute :name

    attributes_to_highlight %i[name]
    searchable_attributes %i[name]
  end
end
