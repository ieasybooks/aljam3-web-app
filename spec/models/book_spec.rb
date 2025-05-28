# == Schema Information
#
# Table name: books
#
#  id         :bigint           not null, primary key
#  author     :string           not null
#  category   :string           not null
#  pages      :integer          not null
#  title      :string           not null
#  volumes    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  library_id :bigint           not null
#
# Indexes
#
#  index_books_on_library_id  (library_id)
#
# Foreign Keys
#
#  fk_rails_...  (library_id => libraries.id)
#
require "rails_helper"

RSpec.describe Book do
  describe "associations" do
    it { is_expected.to belong_to(:library) }
    it { is_expected.to have_many(:files).class_name("BookFile").dependent(:destroy) }
    it { is_expected.to have_many(:pdf_files).class_name("BookFile") }
    it { is_expected.to have_many(:txt_files).class_name("BookFile") }
    it { is_expected.to have_many(:docx_files).class_name("BookFile") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:author) }
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:volumes) }
    it { is_expected.to validate_presence_of(:pages) }
  end
end
