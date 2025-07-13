# == Schema Information
#
# Table name: search_queries
#
#  id          :bigint           not null, primary key
#  query       :string           not null
#  refinements :jsonb            not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint
#
# Indexes
#
#  index_search_queries_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class SearchQuery < ApplicationRecord
  belongs_to :user, optional: true
  has_many :search_clicks, dependent: :delete_all

  validates :query, :refinements, presence: true
  validates :query, length: { minimum: 3, maximum: 255 }
end
