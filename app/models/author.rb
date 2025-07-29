# == Schema Information
#
# Table name: authors
#
#  id          :bigint           not null, primary key
#  books_count :integer          default(0), not null
#  hidden      :boolean          default(FALSE), not null
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Author < ApplicationRecord
  include Meilisearch::Rails

  extend Pagy::Meilisearch
  ActiveRecord_Relation.include Pagy::Meilisearch

  has_many :books, dependent: :destroy
  has_many :search_clicks, as: :result, dependent: :delete_all

  validates :name, :books_count, presence: true
  validates_inclusion_of :hidden, in: [ true, false ]

  meilisearch enqueue: true do
    attribute :name, :hidden

    attributes_to_highlight %i[name]
    searchable_attributes %i[name]
    filterable_attributes %i[hidden]
  end
end
