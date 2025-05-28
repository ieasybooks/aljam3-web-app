# == Schema Information
#
# Table name: pages
#
#  id           :bigint           not null, primary key
#  content      :text             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  book_file_id :bigint           not null
#
# Indexes
#
#  index_pages_on_book_file_id  (book_file_id)
#
# Foreign Keys
#
#  fk_rails_...  (book_file_id => book_files.id)
#
require 'rails_helper'

RSpec.describe Page do
  describe "associations" do
    it { is_expected.to belong_to(:book_file) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:content) }
  end
end
