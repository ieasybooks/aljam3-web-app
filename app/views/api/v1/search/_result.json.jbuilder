# locals: { json:, page: }

json.partial! "api/v1/pages/page", page: page

json.book do
  json.partial! "api/v1/books/book", book: page.file.book
end
