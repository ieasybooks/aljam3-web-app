# == Schema Information
#
# Table name: book_files
#
#  id          :bigint           not null, primary key
#  docx_url    :text             default(""), not null
#  pages_count :integer          default(0), not null
#  pdf_url     :text             default(""), not null
#  txt_url     :text             default(""), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  book_id     :bigint           not null
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
  belongs_to :book, counter_cache: :files_count
  has_many :pages, -> { order(:number) }, dependent: :destroy

  validates :pdf_url, :txt_url, :docx_url, presence: true

  def name = URI.decode_www_form_component(File.basename(pdf_url, File.extname(pdf_url)))
end
