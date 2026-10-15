require "test_helper"

class CategoryTest < ModelTest
  test "has books and requires a name" do
    assert_model_matcher(have_many(:books).dependent(:destroy), Category)
    assert_model_matcher(validate_presence_of(:name), Category)
  end
end
