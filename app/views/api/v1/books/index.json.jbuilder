json.partial! "api/v1/pagination", locals: { pagy: @pagy }

json.books do
  json.array! @books do |book|
    json.partial! "api/v1/books/book", book:
  end
end
