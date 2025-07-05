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
FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
  end
end
