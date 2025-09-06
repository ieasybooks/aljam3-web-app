json.pagination do
  json.from @pagy.from
  json.to @pagy.to
  json.count @pagy.count
  json.current_page @pagy.page
  json.total_pages @pagy.last
  json.next_page @pagy.next
  json.next_page_link @pagy.next ? books_url(page: @pagy.next, format: :json) : nil
  json.previous_page @pagy.prev
  json.previous_page_link @pagy.prev ? books_url(page: @pagy.prev, format: :json) : nil
end

json.books do
  json.array! @books do |book|
    json.id book.id
    json.title book.title

    json.author do
      json.id book.author.id
      json.name book.author.name
      json.ui_link author_url(book.author.id)
      json.api_link author_url(book.author.id, format: :json)
    end

    json.category do
      json.id book.category.id
      json.name book.category.name
      json.ui_link category_url(book.category.id)
      json.api_link category_url(book.category.id, format: :json)
    end

    json.library do
      json.id book.library.id
      json.name book.library.name
    end

    json.pages_count book.pages_count
    json.files_count book.files_count
    json.views_count book.views_count
    json.volumes book.volumes
    json.ui_link book_url(book.id)
    json.api_link book_url(book.id, format: :json)
  end
end
