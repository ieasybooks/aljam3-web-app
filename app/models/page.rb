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
#  index_pages_on_book_file_id_and_number  (book_file_id,number) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (book_file_id => book_files.id)
#
class Page < ApplicationRecord
  include Meilisearch::Rails

  extend Pagy::Meilisearch
  ActiveRecord_Relation.include Pagy::Meilisearch

  belongs_to :file, class_name: "BookFile", foreign_key: "book_file_id", counter_cache: true
  has_many :search_clicks, as: :result, dependent: :delete_all

  validates :content, :number, presence: true

  def hidden = file.book.hidden

  meilisearch enqueue: true do
    attribute :content, :hidden

    attribute :library do
      # :nocov:
      file.book.library_id
      # :nocov:
    end

    attribute :book do
      # :nocov:
      file.book_id
      # :nocov:
    end

    attribute :author do
      # :nocov:
      file.book.author_id
      # :nocov:
    end

    attribute :category do
      # :nocov:
      file.book.category_id
      # :nocov:
    end

    attributes_to_highlight %i[content]
    searchable_attributes %i[content]
    filterable_attributes %i[library book author category hidden]
  end
end
