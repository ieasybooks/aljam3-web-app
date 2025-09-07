json.id book.id
json.title book.title

json.author do
  json.id book.author.id
  json.name book.author.name
  json.link api_v1_author_url(id: book.author.id)
end

json.category do
  json.id book.category.id
  json.name book.category.name
  json.link api_v1_category_url(id: book.category.id)
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
