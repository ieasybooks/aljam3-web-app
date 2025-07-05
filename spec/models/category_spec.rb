# == Schema Information
#
# Table name: categories
#
#  id          :bigint           not null, primary key
#  books_count :integer          default(0), not null
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require "rails_helper"

RSpec.describe Category do
  describe "associations" do
    it { is_expected.to have_many(:books).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end
end
