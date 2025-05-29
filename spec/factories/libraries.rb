FactoryBot.define do
  factory :library do
    sequence(:name) { |n| "Library #{n}" }
  end
end
