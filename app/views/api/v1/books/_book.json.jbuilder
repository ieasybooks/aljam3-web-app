# locals: (json:, book:, exclude: [])

json.id book.id
json.title book.title

if exclude.exclude?(:author)
  json.author do
    json.partial!("api/v1/authors/author", author: book.author)
  end
end

if exclude.exclude?(:category)
  json.category do
    json.partial!("api/v1/categories/category", category: book.category)
  end
end

json.library do
  json.id book.library.id
  json.name book.library.name
end

json.pages_count book.pages_count
json.files_count book.files_count
json.views_count book.views_count
json.volumes book.volumes
json.link api_v1_book_url(id: book.id)
