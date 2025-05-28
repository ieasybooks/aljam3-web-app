# == Schema Information
#
# Table name: book_files
#
#  id         :bigint           not null, primary key
#  file_type  :integer          not null
#  size       :float            not null
#  url        :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :bigint           not null
#
# Indexes
#
#  index_book_files_on_book_id  (book_id)
#
# Foreign Keys
#
#  fk_rails_...  (book_id => books.id)
#
class BookFile < ApplicationRecord
  belongs_to :book
  has_many :pages, dependent: :destroy

  validates :file_type, :url, :size, presence: true

  enum :file_type, { pdf: 0, txt: 1, docx: 2 }
end
