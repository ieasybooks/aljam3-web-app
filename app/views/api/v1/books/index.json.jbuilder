json.partial! "api/v1/pagination", locals: { pagy: @pagy, url_method: :api_v1_books_url }

json.books do
  json.array! @books do |book|
    json.partial! "api/v1/books/book", book:
  end
end
