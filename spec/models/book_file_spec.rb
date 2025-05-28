require 'rails_helper'

RSpec.describe BookFile do
  describe "associations" do
    it { is_expected.to belong_to(:book) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:file_type) }
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_presence_of(:size) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:file_type).with_values(pdf: 0, txt: 1, docx: 2) }
  end
end
