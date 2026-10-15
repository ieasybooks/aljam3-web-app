require "test_helper"

class UserTest < ModelTest
  test "has the expected associations, validations, and role enum" do
    assert_model_matcher(have_many(:search_queries).dependent(:destroy), User)
    assert_model_matcher(have_many(:search_clicks).through(:search_queries), User)
    assert_model_matcher(validate_presence_of(:role), User)
    assert_model_matcher(validate_presence_of(:encrypted_password), User)
    assert_model_matcher(validate_presence_of(:sign_in_count), User)
    assert_model_matcher(validate_presence_of(:failed_attempts), User)
    assert_model_matcher(define_enum_for(:role).with_values(user: 0, admin: 1), User)
  end
end
