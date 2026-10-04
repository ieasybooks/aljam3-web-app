json.id page.id
json.file_id page.book_file_id
json.content process_meilisearch_highlights(page.formatted&.[]("content")) || page.content
json.number page.number
