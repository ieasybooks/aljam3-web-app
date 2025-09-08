# locals: (json:, file:)

json.id file.id
json.name file.name
json.pages_count file.pages_count

json.urls do
  json.pdf file.pdf_url
  json.docx file.docx_url
  json.txt file.txt_url
end

json.link api_v1_book_file_url(book_id: file.book_id, id: file.id)
