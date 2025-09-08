json.partial! "api/v1/authors/author", author: @author

if params[:expand]&.include?("books")
  json.partial! "api/v1/pagination", locals: { pagy: @pagy, url_method: :api_v1_author_url }

  json.books do
    json.array! @books, partial: "api/v1/books/book", as: :book, exclude: %i[author]
  end
end
