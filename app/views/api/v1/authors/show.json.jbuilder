json.partial! "api/v1/authors/author", author: @author

json.partial! "api/v1/pagination", locals: { pagy: @pagy }

json.books do
  json.array! @books do |book|
    json.partial! "api/v1/books/book", book:, exclude: %i[author]
  end
end
