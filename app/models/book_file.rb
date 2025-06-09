# == Schema Information
#
# Table name: book_files
#
#  id         :bigint           not null, primary key
#  docx_size  :float            default(0.0), not null
#  docx_url   :text             default("")
#  pdf_size   :float            default(0.0), not null
#  pdf_url    :text             default("")
#  txt_size   :float            default(0.0), not null
#  txt_url    :text             default("")
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
  has_many :pages, -> { order(:number) }, dependent: :destroy

  validates :pdf_url, :txt_url, :docx_url, :pdf_size, :txt_size, :docx_size, presence: true

  def name = File.basename(pdf_url, File.extname(pdf_url))
end
