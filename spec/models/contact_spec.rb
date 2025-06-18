# == Schema Information
#
# Table name: contacts
#
#  id         :bigint           not null, primary key
#  email      :string(255)      not null
#  message    :text             not null
#  name       :string(255)      not null
#  topic      :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

RSpec.describe Contact do
  describe "validations" do
    subject(:contact) { described_class.new }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:topic) }
    it { is_expected.to validate_presence_of(:message) }

    it { is_expected.to validate_length_of(:name).is_at_least(5).is_at_most(255) }
    it { is_expected.to validate_length_of(:email).is_at_least(5).is_at_most(255) }
    it { is_expected.to validate_length_of(:topic).is_at_least(5).is_at_most(255) }
    it { is_expected.to validate_length_of(:message).is_at_least(15).is_at_most(5000) }

    it "validates email format" do # rubocop:disable RSpec/MultipleExpectations
      expect(contact).to allow_value("user@example.com").for(:email)
      expect(contact).not_to allow_value("invalid_email").for(:email)
      expect(contact).not_to allow_value("invalid@").for(:email)
      expect(contact).not_to allow_value("@invalid.com").for(:email)
    end
  end
end
