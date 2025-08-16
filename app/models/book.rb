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
class Book < ApplicationRecord
  include Meilisearch::Rails

  extend Pagy::Meilisearch
  ActiveRecord_Relation.include Pagy::Meilisearch

  belongs_to :library, counter_cache: true
  belongs_to :author, counter_cache: true
  belongs_to :category, counter_cache: true
  has_many :files, -> { order(:id) }, class_name: "BookFile", dependent: :destroy
  has_many :pages, -> { order(:id, :number) }, through: :files
  has_many :search_clicks, as: :result, dependent: :delete_all

  validates :title, :volumes, :pages_count, :views_count, presence: true
  validates_inclusion_of :hidden, in: [ true, false ]

  scope :most_viewed, ->(limit = 10) { where(hidden: false).order(views_count: :desc).limit(limit) }

  meilisearch enqueue: true do
    attribute :title, :hidden

    attribute :library do
      # :nocov:
      library_id
      # :nocov:
    end

    attribute :author do
      # :nocov:
      author_id
      # :nocov:
    end

    attribute :category do
      # :nocov:
      category_id
      # :nocov:
    end

    attributes_to_highlight %i[title]
    searchable_attributes %i[title]
    filterable_attributes %i[library author category hidden]
  end

  def increment_views! = increment!(:views_count)
end
