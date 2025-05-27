# == Schema Information
#
# Table name: libraries
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Library do
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end
end
