# locals: (json:, author:)

json.id author.id
json.name process_meilisearch_highlights(author.formatted&.[]("name")) || author.name
json.books_count author.books_count
json.link api_v1_author_url(id: author.id)
