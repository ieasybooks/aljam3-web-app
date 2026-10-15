require "test_helper"

class SearchQueryTest < ModelTest
  test "has the expected association and validations" do
    assert_model_matcher(belong_to(:user).optional, SearchQuery)
    assert_model_matcher(have_many(:search_clicks).dependent(:delete_all), SearchQuery)
    assert_model_matcher(validate_presence_of(:query), SearchQuery)
    assert_model_matcher(validate_presence_of(:refinements), SearchQuery)
    assert_model_matcher(validate_length_of(:query).is_at_least(3).is_at_most(255), SearchQuery)
  end
end
