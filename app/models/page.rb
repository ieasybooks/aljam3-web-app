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
  belongs_to :book_file

  validates :content, presence: true
end
