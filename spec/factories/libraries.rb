# == Schema Information
#
# Table name: libraries
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :library do
    sequence(:name) { |n| "Library #{n}" }

    trait :with_books do
      transient do
        books_count { 3 }
      end

      after(:create) do |library, evaluator|
        create_list(:book, evaluator.books_count, :with_files, library:)
      end
    end
  end
end
