require "test_helper"

class LibraryTest < ModelTest
  test "has books and requires a name" do
    assert_model_matcher(have_many(:books).dependent(:destroy), Library)
    assert_model_matcher(validate_presence_of(:name), Library)
  end
end
