require 'faker'

User.new(email: "aljam3@ieasybooks.com", password: "aljam3@ieasybooks.com", role: :admin).tap(&:skip_confirmation!).save

Library.find_or_create_by(name: "المكتبة الشاملة الوقفية")
Library.find_or_create_by(name: "المكتبة الوقفية")
Library.find_or_create_by(name: "مكتبة المسجد النبوي")

if Book.count == 0
  10.times do
    library = Library.all.sample
    volumes = Random.rand(1..5)
    volumes_pages = ([ 0 ] * volumes).map { Random.rand(25..500) }
    pages = volumes_pages.sum

    book = library.books.create(
      title: Faker::Book.title,
      author: Faker::Book.author,
      category: Faker::Book.genre,
      volumes:,
      pages:
    )

    volumes.times do |index|
      book.files.create(
        file_type: :pdf,
        url: "https://example.com/book-#{book.id}-file-#{index + 1}.pdf",
        size: Random.rand(0.0..50.0)
      )

      txt_book_file = book.files.create(
        file_type: :txt,
        url: "https://example.com/book-#{book.id}-file-#{index + 1}.txt",
        size: Random.rand(0.0..5.0)
      )

      book.files.create(
        file_type: :docx,
        url: "https://example.com/book-#{book.id}-file-#{index + 1}.docx",
        size: Random.rand(0.0..10.0)
      )

      txt_book_file.pages.insert_all(
        ([ 0 ] * volumes_pages[index]).map.with_index do |_value, jndex|
          {
            content: Faker::Lorem.paragraph,
            number: jndex,
            book_file_id: txt_book_file.id
          }
        end
      )
    end
  end

  Page.reindex!

  puts "Waiting for Meilisearch to finish indexing ⌛"
  sleep 1 while Page.index.stats["isIndexing"]
  puts "Meilisearch finished indexing 🚀"
end
