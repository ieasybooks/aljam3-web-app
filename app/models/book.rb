# == Schema Information
#
# Table name: books
#
#  id         :bigint           not null, primary key
#  author     :string           not null
#  category   :string           not null
#  pages      :integer          not null
#  title      :string           not null
#  volumes    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  library_id :bigint           not null
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
  belongs_to :library

  validates :title, :author, :category, :volumes, :pages, presence: true
end
