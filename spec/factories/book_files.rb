# == Schema Information
#
# Table name: book_files
#
#  id          :bigint           not null, primary key
#  docx_url    :text             default("")
#  pages_count :integer          default(0), not null
#  pdf_url     :text             default("")
#  txt_url     :text             default("")
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  book_id     :bigint           not null
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
    pdf_url { "https://example.com/files/file_1.pdf" }
    txt_url { "https://example.com/files/file_1.txt" }
    docx_url { "https://example.com/files/file_1.docx" }

    association :book

    trait :with_pages do
      transient do
        pages_count { 5 }
      end

      after(:create) do |book_file, evaluator|
        evaluator.pages_count.times do |page_number|
          create(:page, number: page_number + 1, file: book_file)
        end
      end
    end
  end
end
