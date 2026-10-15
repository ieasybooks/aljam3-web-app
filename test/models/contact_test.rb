require "test_helper"

class ContactTest < ModelTest
  test "has the expected presence and length validations" do
    assert_model_matcher(validate_presence_of(:name), Contact)
    assert_model_matcher(validate_presence_of(:email), Contact)
    assert_model_matcher(validate_presence_of(:topic), Contact)
    assert_model_matcher(validate_presence_of(:message), Contact)
    assert_model_matcher(validate_length_of(:name).is_at_least(5).is_at_most(255), Contact)
    assert_model_matcher(validate_length_of(:email).is_at_least(5).is_at_most(255), Contact)
    assert_model_matcher(validate_length_of(:topic).is_at_least(5).is_at_most(255), Contact)
    assert_model_matcher(validate_length_of(:message).is_at_least(15).is_at_most(5000), Contact)
  end

  test "accepts a valid email address" do
    assert build_contact(email: "user@example.com").valid?
  end

  test "rejects malformed email addresses" do
    %w[invalid_email invalid@ @invalid.com].each do |email|
      refute build_contact(email:).valid?, "expected #{email} to be rejected"
    end
  end

  private

  def build_contact(email:)
    Contact.new(name: "Valid name", email:, topic: "Valid topic", message: "A valid message.")
  end
end
