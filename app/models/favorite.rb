# == Schema Information
#
# Table name: favorites
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_favorites_on_book_id              (book_id)
#  index_favorites_on_user_id              (user_id)
#  index_favorites_on_user_id_and_book_id  (user_id,book_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (book_id => books.id)
#  fk_rails_...  (user_id => users.id)
#
class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :book

  # Ensure a user can only favorite a book once
  validates :user_id, uniqueness: { scope: :book_id }
  validates :user_id, presence: true
  validates :book_id, presence: true
end
