# == Schema Information
#
# Table name: books
#
#  id          :bigint           not null, primary key
#  files_count :integer          default(0), not null
#  pages_count :integer          not null
#  title       :string           not null
#  volumes     :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  author_id   :bigint           not null
#  category_id :bigint           not null
#  library_id  :bigint           not null
#
# Indexes
#
#  index_books_on_author_id    (author_id)
#  index_books_on_category_id  (category_id)
#  index_books_on_library_id   (library_id)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => authors.id)
#  fk_rails_...  (category_id => categories.id)
#  fk_rails_...  (library_id => libraries.id)
#
FactoryBot.define do
  factory :book do
    sequence(:title) { |n| "Title #{n}" }
    author { create(:author) }
    category { create(:category) }
    volumes { rand(1..5) }
    pages_count { rand(1..10) }

    association :library

    trait :with_files do
      transient do
        files_count { nil }
      end

      after(:create) do |book, evaluator|
        final_files_count = evaluator.files_count || Random.rand(book.volumes..(book.volumes + 2))

        book.update(volumes: final_files_count) if evaluator.files_count.present?

        pages_per_file = book.pages_count / final_files_count
        remaining_pages = book.pages_count % final_files_count

        final_files_count.times do |index|
          create(:book_file, :with_pages, pages_count: pages_per_file + (index < remaining_pages ? 1 : 0), book:)
        end
      end
    end
  end
end
