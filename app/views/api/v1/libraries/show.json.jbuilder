json.partial! "api/v1/libraries/library", library: @library

if params[:expand]&.include?("books")
  json.partial! "api/v1/pagination", locals: { pagy: @pagy, url_method: :api_v1_library_url }

  json.books do
    json.array! @books, partial: "api/v1/books/book", as: :book, exclude: %i[library]
  end
end
