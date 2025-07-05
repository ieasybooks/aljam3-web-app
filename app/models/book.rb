# == Schema Information
#
# Table name: books
#
#  id          :bigint           not null, primary key
#  category    :string           not null
#  files_count :integer          default(0), not null
#  pages_count :integer          not null
#  title       :string           not null
#  volumes     :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  author_id   :bigint           not null
#  library_id  :bigint           not null
#
# Indexes
#
#  index_books_on_author_id   (author_id)
#  index_books_on_library_id  (library_id)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => authors.id)
#  fk_rails_...  (library_id => libraries.id)
#
class Book < ApplicationRecord
  include Meilisearch::Rails

  extend Pagy::Meilisearch
  ActiveRecord_Relation.include Pagy::Meilisearch

  belongs_to :library, counter_cache: true
  belongs_to :author, counter_cache: true
  has_many :files, -> { order(:id) }, class_name: "BookFile", dependent: :destroy
  has_many :pages, -> { order(:id, :number) }, through: :files

  validates :title, :category, :volumes, :pages_count, presence: true

  meilisearch enqueue: true do
    attribute :title, :category

    attribute :author do
      # :nocov:
      author_id
      # :nocov:
    end

    attribute :library do
      # :nocov:
      library_id
      # :nocov:
    end

    attributes_to_highlight %i[title]
    searchable_attributes %i[title]
    filterable_attributes %i[category author library]
  end
end
