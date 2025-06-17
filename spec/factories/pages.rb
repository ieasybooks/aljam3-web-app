# == Schema Information
#
# Table name: pages
#
#  id           :bigint           not null, primary key
#  content      :text             not null
#  number       :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  book_file_id :bigint           not null
#
# Indexes
#
#  index_pages_on_book_file_id_and_number  (book_file_id,number) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (book_file_id => book_files.id)
#
FactoryBot.define do
  factory :page do
    sequence(:number) { |n| n }
    sequence(:content) { |n| "This is the content of page #{n}. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat." }

    association :file, factory: :book_file
  end
end
