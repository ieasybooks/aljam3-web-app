# == Schema Information
#
# Table name: book_files
#
#  id         :bigint           not null, primary key
#  file_type  :integer          not null
#  size       :float            not null
#  url        :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :bigint           not null
#
# Indexes
#
#  index_book_files_on_book_id  (book_id)
#
# Foreign Keys
#
#  fk_rails_...  (book_id => books.id)
#
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
