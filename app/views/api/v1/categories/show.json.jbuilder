json.partial! "api/v1/categories/category", category: @category

if params[:expand]&.include?("books")
  json.partial! "api/v1/pagination", locals: { pagy: @pagy, url_method: :api_v1_category_url }

  json.books do
    json.array! @books, partial: "api/v1/books/book", as: :book, exclude: %i[category]
  end
end
