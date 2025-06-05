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
FactoryBot.define do
  factory :book do
    sequence(:title) { |n| "Title #{n}" }
    sequence(:author) { |n| "Author #{n}" }
    category { [ "Fiction", "Non-Fiction", "Science", "History", "Biography" ].sample }
    volumes { rand(1..5) }
    pages { rand(1..10) }

    association :library

    trait :with_files do
      after(:create) do |book|
        pages_per_file = book.pages / book.volumes
        remaining_pages = book.pages % book.volumes

        book.volumes.times do |index|
          create(:book_file, :pdf, book:)
          create(:book_file, :txt, :with_pages, pages_count: pages_per_file + (index < remaining_pages ? 1 : 0), book:)
          create(:book_file, :docx, book:)
        end
      end
    end
  end
end
