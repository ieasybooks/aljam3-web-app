# == Schema Information
#
# Table name: pages
#
#  id           :bigint           not null, primary key
#  content      :text             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  book_file_id :bigint           not null
#
# Indexes
#
#  index_pages_on_book_file_id  (book_file_id)
#
# Foreign Keys
#
#  fk_rails_...  (book_file_id => book_files.id)
#
class Page < ApplicationRecord
  include Meilisearch::Rails

  belongs_to :file, class_name: "BookFile", foreign_key: "book_file_id"

  validates :content, presence: true

  meilisearch enqueue: true do
    attribute :content

    attribute :category do
      # :nocov:
      file.book.category
      # :nocov:
    end

    attribute :author do
      # :nocov:
      file.book.author
      # :nocov:
    end

    attribute :book do
      # :nocov:
      file.book_id
      # :nocov:
    end

    attribute :library do
      # :nocov:
      file.book.library_id
      # :nocov:
    end

    searchable_attributes %i[content]
    filterable_attributes %i[category author book library]
  end
end
