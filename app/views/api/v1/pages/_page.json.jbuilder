json.id page.id
json.content process_meilisearch_highlights(page.formatted&.[]("content")) || page.content
json.number page.number
