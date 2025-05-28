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
      file.book.category
    end

    attribute :author do
      file.book.author
    end

    attribute :book do
      file.book_id
    end

    attribute :library do
      file.book.library_id
    end

    searchable_attributes %i[content]
    filterable_attributes %i[category author book library]
  end
end
