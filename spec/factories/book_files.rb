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
FactoryBot.define do
  factory :book_file do
    file_type { :pdf }
    sequence(:url) { |n| "https://example.com/files/file_#{n}.pdf" }
    size { rand(1.0..10.0).round(2) }

    association :book

    trait :pdf do
      file_type { :pdf }
      url { "https://example.com/files/document.pdf" }
    end

    trait :txt do
      file_type { :txt }
      url { "https://example.com/files/document.txt" }
    end

    trait :docx do
      file_type { :docx }
      url { "https://example.com/files/document.docx" }
    end

    trait :with_pages do
      transient do
        pages_count { 5 }
      end

      after(:create) do |book_file, evaluator|
        if book_file.txt?
          evaluator.pages_count.times do |page_number|
            create(:page, number: page_number + 1, file: book_file)
          end
        end
      end
    end
  end
end
