# == Schema Information
#
# Table name: search_clicks
#
#  id              :bigint           not null, primary key
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
    it { is_expected.to belong_to(:result).polymorphic }
    it { is_expected.to belong_to(:search_query) }
  end
end
