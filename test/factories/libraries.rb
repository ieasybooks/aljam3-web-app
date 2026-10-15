# == Schema Information
#
# Table name: libraries
#
#  id          :bigint           not null, primary key
#  books_count :integer          default(0), not null
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :library do
    sequence(:name) { |n| "Library #{n}" }

    trait :with_books do
      transient do
        books_count { 3 }
        deterministic_files_count { false }
      end

      after(:create) do |library, evaluator|
        if evaluator.deterministic_files_count
          create_list(:book, evaluator.books_count, :with_files, files_count: Random.rand(1..5), library:)
        else
          create_list(:book, evaluator.books_count, :with_files, library:)
        end
      end
    end
  end
end
