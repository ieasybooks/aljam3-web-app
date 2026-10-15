require "test_helper"

class SearchClickTest < ModelTest
  test "has the expected associations and index validations" do
    assert_model_matcher(belong_to(:result), SearchClick)
    assert_model_matcher(belong_to(:search_query), SearchClick)
    assert_model_matcher(validate_presence_of(:index), SearchClick)
    assert_model_matcher(validate_numericality_of(:index).only_integer.is_greater_than_or_equal_to(-1), SearchClick)
  end
end
