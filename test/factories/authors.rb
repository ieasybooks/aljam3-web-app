# == Schema Information
#
# Table name: authors
#
#  id          :bigint           not null, primary key
#  books_count :integer          default(0), not null
#  hidden      :boolean          default(FALSE), not null
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :author do
    sequence(:name) { |n| "Author #{n}" }
  end
end
