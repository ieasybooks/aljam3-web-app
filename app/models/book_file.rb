class BookFile < ApplicationRecord
  belongs_to :book

  validates :file_type, :url, :size, presence: true

  enum :file_type, { pdf: 0, txt: 1, docx: 2 }
end
