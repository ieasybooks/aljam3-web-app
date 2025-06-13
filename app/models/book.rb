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
class Book < ApplicationRecord
  include Meilisearch::Rails

  extend Pagy::Meilisearch
  ActiveRecord_Relation.include Pagy::Meilisearch

  belongs_to :library, counter_cache: true
  has_many :files, -> { order(:id) }, class_name: "BookFile", dependent: :destroy

  validates :title, :author, :category, :volumes, :pages, presence: true

  meilisearch enqueue: true do
    attribute :title, :category, :author

    attribute :library do
      # :nocov:
      library_id
      # :nocov:
    end

    attributes_to_highlight %i[title]
    searchable_attributes %i[title]
    filterable_attributes %i[category author library]
  end

  def first_page = files.first.pages.first
end
