# == Schema Information
#
# Table name: libraries
#
#  id          :bigint           not null, primary key
#  books_count :integer          default(0), not null
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Library < ApplicationRecord
  has_many :books, dependent: :destroy

  validates :name, presence: true
end
