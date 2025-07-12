# == Schema Information
#
# Table name: search_queries
#
#  id          :bigint           not null, primary key
#  query       :string
#  refinements :jsonb
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
require "rails_helper"

RSpec.describe SearchQuery do
  describe "associations" do
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to have_many(:search_clicks).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:query) }
    it { is_expected.to validate_presence_of(:refinements) }
    it { is_expected.to validate_length_of(:query).is_at_least(3).is_at_most(255) }
  end
end
