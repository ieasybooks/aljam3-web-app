# == Schema Information
#
# Table name: search_clicks
#
#  id              :bigint           not null, primary key
#  index           :integer          default(-1), not null
#  result_type     :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  result_id       :bigint           not null
#  search_query_id :bigint           not null
#
# Indexes
#
#  index_search_clicks_on_result           (result_type,result_id)
#  index_search_clicks_on_search_query_id  (search_query_id)
#
# Foreign Keys
#
#  fk_rails_...  (search_query_id => search_queries.id)
#
RSpec.describe SearchClick do
  describe "associations" do
    it { is_expected.to belong_to(:result) }
    it { is_expected.to belong_to(:search_query) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:index) }
    it { is_expected.to validate_numericality_of(:index).only_integer.is_greater_than_or_equal_to(-1) }
  end
end
